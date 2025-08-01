data "template_file" "karpenter_values" {
  count    = var.autoscaler == "karpenter" ? 1 : 0
  template = file("${path.module}/templates/karpenter-values.yaml")
  vars = {
    CLUSTER_NAME   = local.cluster_name
    CLUSTER_REGION = var.app_region
    ACCOUNT_ID     = data.aws_caller_identity.current.account_id
    cluster_endpoint  = module.eks.cluster_endpoint
    irsa_arn          = module.karpenter_irsa[0].iam_role_arn
  }
}
locals {
  total_cpu_limit    = var.node_config.cpu * var.node_config.max_count
  total_memory_limit = "${var.node_config.memory * var.node_config.max_count}Gi"
}

data "template_file" "karpenter_nodepool" {
  count    = var.autoscaler == "karpenter" ? 1 : 0
  template = file("${path.module}/templates/karpenter-nodepool.yaml")

  vars = {
    CPU_LIMIT    = local.total_cpu_limit
    MEMORY_LIMIT = local.total_memory_limit
  }
}

data "template_file" "karpenter_nodeclass" {
  count    = var.autoscaler == "karpenter" ? 1 : 0
  template = file("${path.module}/templates/karpenter-ec2-nodeclass.yaml")
  vars = {
    CLUSTER_NAME = local.cluster_name
    ACCOUNT_ID   = data.aws_caller_identity.current.account_id
  }
}
resource "local_file" "karpenter_nodeclass" {
  count    = var.autoscaler == "karpenter" ? 1 : 0
  content  = data.template_file.karpenter_nodeclass[0].rendered
  filename = "${path.module}/karpenter-ec2-nodeclass.yaml"
}

resource "kubernetes_namespace" "karpenter" {
  count = var.autoscaler == "karpenter" ? 1 : 0

  metadata {
    name = "karpenter"
  }
}

resource "helm_release" "karpenter" {
  count      = var.autoscaler == "karpenter" ? 1 : 0
  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  namespace  = "karpenter"
  version    = "v0.34.0"

  values = [data.template_file.karpenter_values[0].rendered]

  depends_on = [
    null_resource.wait_for_cluster,
    kubernetes_namespace.karpenter
  ]
}

resource "aws_iam_policy" "karpenter_controller" {
  count       = var.autoscaler == "karpenter" ? 1 : 0
  name        = "${local.cluster_name}-karpenter-controller-policy"
  description = "IAM policy for Karpenter controller"
  policy      = file("${path.module}/templates/karpenter-iam-policy.json")
}

module "karpenter_irsa" {
  count = var.autoscaler == "karpenter" ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.30.0"

  create_role                   = true
  role_name                     = "${local.cluster_name}-karpenter-controller"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.karpenter_controller[0].arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:karpenter:karpenter"]

  tags = local.common_tags
}

resource "kubernetes_service_account" "karpenter" {
  count = var.autoscaler == "karpenter" ? 1 : 0

  metadata {
    name      = "karpenter"
    namespace = "karpenter"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.karpenter_irsa[0].iam_role_arn
    }
  }

  depends_on = [
    helm_release.karpenter,
    kubernetes_namespace.karpenter
  ]
}

resource "null_resource" "karpenter_manifests" {
  count = var.autoscaler == "karpenter" ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
      kubectl apply -f ${local_file.karpenter_nodeclass[0].filename}
      echo '${data.template_file.karpenter_nodepool[0].rendered}' | kubectl apply -f -
    EOT
  }

  depends_on = [
    helm_release.karpenter,
    local_file.karpenter_nodeclass
  ]
}
