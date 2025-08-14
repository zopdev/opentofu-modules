provider "aws" {
  region = var.app_region
}

# -------------------------------------------------------
# IAM Roles for Karpenter (only if autoscaler == "karpenter")
# -------------------------------------------------------
resource "aws_iam_role" "karpenter_node_role" {
  count              = var.karpenter_configs.enable ? 1 : 0
  name               = "KarpenterNodeRole-${local.cluster_name}"
  assume_role_policy = file("./templates/karpenter-node-trust-policy-official.json")
}

resource "aws_iam_role_policy_attachment" "node_policies" {
  count      = var.karpenter_configs.enable ? length(local.node_policy_arns) : 0
  role       = "KarpenterNodeRole-${local.cluster_name}" // can also use aws_iam_role.karpenter_node_role[0].name
  policy_arn = local.node_policy_arns[count.index]
}

locals {
  node_policy_arns = [
    "arn:${var.aws_partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:${var.aws_partition}:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:${var.aws_partition}:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    "arn:${var.aws_partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

resource "aws_iam_role" "karpenter_controller_role" {
  count              = var.karpenter_configs.enable ? 1 : 0
  name               = "KarpenterControllerRole-${local.cluster_name}"
  assume_role_policy = templatefile("./templates/karpenter-controller-trust-policy-official.json", {
    AWS_PARTITION       = data.aws_partition.current.partition
    AWS_ACCOUNT_ID      = data.aws_caller_identity.current.account_id
    OIDC_ENDPOINT       = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
    KARPENTER_NAMESPACE = var.karpenter_namespace
  })
}


resource "aws_iam_role_policy" "karpenter_controller_policy" {
  count= var.karpenter_configs.enable ? 1 : 0
  name = "KarpenterControllerPolicy-${local.cluster_name}"
  role = aws_iam_role.karpenter_controller_role.name

  policy = templatefile("./templates/karpenter-controller-iam-policy-official.json", {
    AWS_PARTITION = data.aws_partition.current.partition
    AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
    CLUSTER_NAME = local.cluster_name
    AWS_REGION = var.app_region
  })
}

# Tag private subnets for Karpenter
resource "aws_ec2_tag" "karpenter_subnet_tags" {
  for_each = var.karpenter_configs.enable ? toset(var.subnets.private_subnets) : {}

  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = local.cluster_name
}


# Tag security groups for Karpenter
resource "aws_ec2_tag" "karpenter_sg_tags" {
  for_each = var.karpenter_configs.enable ? toset(var.node_security_group_ids) : {}

  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = local.cluster_name
}



data "aws_eks_cluster" "this" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = local.cluster_name
}


# Fetch the existing aws-auth ConfigMap
data "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}

# Update aws-auth to include Karpenter node role
resource "kubernetes_config_map" "aws_auth_update" {
  count = var.karpenter_configs.enable ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(
      concat(
        yamldecode(coalesce(data.kubernetes_config_map.aws_auth.data["mapRoles"], "[]")),
        [
          {
            rolearn  = aws_iam_role.karpenter_node_role[0].arn
            username = "system:node:{{EC2PrivateDNSName}}"
            groups   = ["system:bootstrappers", "system:nodes"]
          }
        ]
      )
    )
  }
}
# -------------------------------------------------------
# Helm Release for Karpenter (only if autoscaler == "karpenter")
# -------------------------------------------------------
resource "helm_release" "karpenter" {
  count      = var.karpenter_configs.enable ? 1 : 0
  name       = "karpenter"
  namespace  = var.karpenter_namespace
  chart      = "karpenter"
  repository = "oci://public.ecr.aws/karpenter/karpenter"
  version    = var.karpenter_version

  values = [
    templatefile("./templates/karpenter-values-official.yaml", {
      CLUSTER_NAME = local.cluster_name
      AWS_PARTITION = var.aws_partition
      AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
    })
  ]
}


locals {
  ec2nodeclass_yaml = templatefile("./templates/karpenter-ec2-nodeclass.yaml", {
    CLUSTER_NAME  = local.cluster_name
    ALIAS_VERSION = var.ami_version
  })
}

resource "kubernetes_manifest" "karpenter_nodeclass" {
  count    = var.karpenter_configs.enable ? 1 : 0
  manifest = yamldecode(local.ec2nodeclass_yaml)
}

locals {
  nodepool_yaml = templatefile("./templates/karpenter-nodepool-final.yaml", {
    CPU_LIMIT       = var.node_config.cpu * var.node_config.max_count
    INSTANCE_TYPES  = var.karpenter_configs.machine_types
    CAPACITY_TYPE   = var.karpenter_configs.capacity_types
  })
}

resource "kubernetes_manifest" "karpenter_nodepool" {
  count    = var.karpenter_configs.enable ? 1 : 0
  manifest = yamldecode(local.nodepool_yaml)
}






#............

