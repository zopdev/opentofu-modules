locals {
  oidc_issuer_url = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].all_outputs.oidc_issuer_url : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].all_outputs.oidc_issuer_url : module.remote_state_azure_cluster[0].all_outputs.oidc_issuer_url)
}

module "iam_assumable_role_admin" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version          = "3.6.0"
  create_role      = true
  role_name        = "${local.cluster_name}-${var.namespace}-oidc-role"
  provider_url     = replace(local.oidc_issuer_url, "https://", "")
  role_policy_arns = [aws_iam_policy.oidc_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:secrets-account"]
  tags = local.common_tags
}

resource "aws_iam_policy" "oidc_policy" {
  name_prefix = "${local.cluster_name}-${var.namespace}-oidc-policy"
  description = "EKS cluster-OIDC policy for namespace ${var.namespace} cluster ${local.cluster_name}"
  policy      = data.aws_iam_policy_document.oidc_policy_document.json
  tags        = local.common_tags
}

data "aws_iam_policy_document" "oidc_policy_document" {
  statement {
    sid    = "GetSecrets"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret",
    ]

    resources = ["arn:aws:secretsmanager:${var.app_region}:${data.aws_caller_identity.current.account_id}:secret:${local.cluster_name}-*"]
  }

}
