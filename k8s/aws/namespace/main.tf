resource "kubernetes_namespace" "app_environments" {

  metadata {
    name = var.namespace
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "aws_iam_policy" "service_policy" {
  name        = "${local.cluster_name}-${var.namespace}-service-policy"
  description = "Allows IAM users to access EKS namespaces and ECR repositories"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "eks:ListClusters",
          "eks:DescribeCluster",
          "eks:AccessKubernetesApi"
        ],
        Resource = "arn:aws:eks:${var.app_region}:${data.aws_caller_identity.current.account_id}:cluster/${local.cluster_name}",
        Condition = {
          StringEquals = {
            "eks:ResourceTag/Namespace" = var.namespace
          }
        }
      },
      {
        "Sid": "ECRUploadAccess",
        "Effect": "Allow",
        "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:PutImage",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        "Resource": "*"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

resource "aws_iam_user" "namespace_users" {
  for_each = var.services
  name     = "${each.value.service_deployer}-${var.namespace}-user"
}

resource "aws_iam_user_policy_attachment" "service_policy_attachment" {
  for_each = var.services
  user = each.value.service_deployer
  policy_arn = aws_iam_policy.service_policy.arn
}

resource "aws_iam_user_policy_attachment" "namespace_user_policy" {
  for_each   = var.services
  user       = aws_iam_user.namespace_users[each.key].name
  policy_arn = aws_iam_policy.service_policy.arn
}

resource "aws_iam_access_key" "user_credentials" {
  for_each = var.services
  user = each.value.service_deployer
}

resource "aws_secretsmanager_secret" "access_key_id" {
  for_each = var.services
  name = "${var.namespace}_${each.value.service_deployer}_ACCESS_KEY_ID"
}

resource "aws_iam_access_key" "namespace_user_keys" {
  for_each = var.services
  user     = aws_iam_user.namespace_users[each.key].name
}

resource "aws_secretsmanager_secret_version" "access_key_id_version" {
  for_each = var.services
  secret_id     = aws_secretsmanager_secret.access_key_id[each.key].id
  secret_string = aws_iam_access_key.user_credentials[each.key].id
}
resource "aws_secretsmanager_secret" "secret_access_key" {
  for_each = var.services
  name = "${var.namespace}_${each.value.service_deployer}_ACCESS_SECRET_KEY"
}

resource "aws_secretsmanager_secret_version" "secret_access_key_version" {
  for_each = var.services
  secret_id     = aws_secretsmanager_secret.secret_access_key[each.key].id
  secret_string = aws_iam_access_key.user_credentials[each.key].secret
}