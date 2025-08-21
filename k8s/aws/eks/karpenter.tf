locals{
  instance_type = length(var.karpenter_configs.machine_types) > 0 ? var.karpenter_configs.machine_types : ["t3.medium", "t3.large"]
  capacity_type = length(var.karpenter_configs.capacity_types) > 0 ? var.karpenter_configs.capacity_types : ["on-demand"]
  enable_karpenter = var.karpenter_configs.enable != null ? var.karpenter_configs.enable : false
}

resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
  }
}

module "karpenter" {
  count     = local.enable_karpenter ? 1 : 0
  source = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.37.2"

  cluster_name = local.cluster_name

  create_node_iam_role = true
  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEKSWorkerNodePolicy = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    AmazonEC2ContainerRegistryPullOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  }

  create_iam_role = true
  namespace       = kubernetes_namespace.karpenter.metadata[0].name
}

data "aws_partition" "current" {}

provider "aws"{
  region = "us-east-1"
  alias  = "virginia"
}
data "aws_ecrpublic_authorization_token" "token"{
  provider = aws.virginia
}
resource "helm_release" "karpenter" {
  count      = local.enable_karpenter ? 1 : 0
  name       = "karpenter-aws"
  namespace  = kubernetes_namespace.karpenter.metadata[0].name
  chart      = "oci://public.ecr.aws/karpenter/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  version    = "1.6.0"

  values = [
    templatefile("./templates/karpenter-values.yaml", {
      CLUSTER_NAME     = local.cluster_name
      CLUSTER_ENDPOINT = module.eks.cluster_endpoint
      QUEUE_NAME = module.karpenter.queue_name
      SA_NAME    = module.karpenter.service_account
    })
  ]
  depends_on = [module.karpenter]
}
#-------------------
# nodeclass & nodepool

resource "kubectl_manifest" "karpenter_nodeclass" {
  count     = local.enable_karpenter ? 1 : 0
  yaml_body = templatefile("./templates/karpenter-ec2-nodeclass.yaml", {
    CLUSTER_NAME = local.cluster_name
    NODE_ROLE    = module.karpenter[0].node_iam_role_name
  })
  depends_on = [helm_release.karpenter]
}

resource "kubectl_manifest" "karpenter_nodepool" {
  count     = local.enable_karpenter ? 1 : 0
  yaml_body = templatefile("./templates/karpenter-nodepool.yaml", {
    INSTANCE_TYPES = local.instance_type
    CAPACITY_TYPE  = local.capacity_type
  })
  depends_on = [helm_release.karpenter]
}






