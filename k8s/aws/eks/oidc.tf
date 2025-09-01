module "iam_assumable_role_admin" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version          = "5.6.0"
  create_role      = true
  role_name        = "${local.cluster_name}-oidc-role"
  provider_url     = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns = [aws_iam_policy.oidc_policy.arn]
  oidc_fully_qualified_subjects = concat(["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"],["system:serviceaccount:cert-manager:${local.cluster_name}-cert-manager"]
  )
  tags = local.common_tags
}

locals {
  k8s_service_account_namespace = "kube-system"
  k8s_service_account_name      = "cluster-oidc-service-account"
}

resource "aws_iam_policy" "oidc_policy" {
  name_prefix = "${local.cluster_name}-oidc-policy"
  description = "EKS cluster-OIDC policy for cluster ${local.cluster_name}"
  policy      = data.aws_iam_policy_document.oidc_policy_document.json
  tags        = local.common_tags
}

data "aws_iam_policy_document" "oidc_policy_document" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${local.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}
