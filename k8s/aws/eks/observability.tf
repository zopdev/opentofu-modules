locals {
  enable_loki   = try(var.observability_config.loki != null ? var.observability_config.loki.enable : false, false)
  enable_tempo  = try(var.observability_config.tempo != null ? var.observability_config.tempo.enable : false, false)
  enable_cortex = try(var.observability_config.cortex != null ? var.observability_config.cortex.enable : false, false)
  enable_mimir  = try(var.observability_config.mimir != null ? var.observability_config.mimir.enable : false, false)
}

module "observability" {
  count  = (local.enable_cortex || local.enable_loki || local.enable_tempo || local.enable_mimir) ? 1 : 0
  source = "../../../observability/aws"

  app_name             = var.app_name
  app_region           = var.app_region
  app_env              = var.app_env
  observability_suffix = var.observability_config.suffix
  access_key           = aws_iam_access_key.observability_s3_user.0.id
  access_secret        = aws_iam_access_key.observability_s3_user.0.secret
  domain_name          = local.domain_name
  cluster_name         = local.cluster_name
  loki                 = var.observability_config.loki
  tempo                = var.observability_config.tempo
  cortex               = var.observability_config.cortex
  mimir                = var.observability_config.mimir
  depends_on           = [helm_release.prometheus, helm_release.k8s_replicator]
}

resource "aws_iam_policy" "observability_s3_iam_policy" {
  count       = (local.enable_cortex || local.enable_loki || local.enable_tempo || local.enable_mimir) ? 1 : 0
  name        = "observability-${local.environment}-policy"
  description = "IAM policy for Observability Cluster to access S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Sid" : "AllObjectActions",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${local.cluster_name}-*-${var.observability_config.suffix}/*"
        ]
      },
      {
        "Sid" : "BucketManagement",
        "Effect" : "Allow",
        "Action" : [
          "s3:CreateBucket",
          "s3:ListBucket"
        ],
        Resource = "arn:aws:s3:::${local.cluster_name}-*-${var.observability_config.suffix}"
      },
      {
        "Sid" : "ListAllBuckets",
        "Effect" : "Allow",
        "Action" : "s3:ListAllMyBuckets",
        "Resource" : "*"
      },
      {
        "Sid" : "DynamoDB",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:CreateTable",
          "dynamodb:DescribeTable",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem",
          "dynamodb:ListTables",
          "dynamodb:ListTagsOfResource"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_user" "observability_s3_user" {
  count = (local.enable_cortex || local.enable_loki || local.enable_tempo || local.enable_mimir) ? 1 : 0
  name  = "${local.cluster_name}-s3-user"
  tags  = local.common_tags
}

resource "aws_iam_user_policy_attachment" "observability_s3_attach" {
  count      = (local.enable_cortex || local.enable_loki || local.enable_tempo || local.enable_mimir) ? 1 : 0
  user       = aws_iam_user.observability_s3_user.0.name
  policy_arn = aws_iam_policy.observability_s3_iam_policy.0.arn
}

resource "aws_iam_access_key" "observability_s3_user" {
  count = (local.enable_cortex || local.enable_loki || local.enable_tempo || local.enable_mimir) ? 1 : 0
  user  = aws_iam_user.observability_s3_user.0.name
}

resource "aws_secretsmanager_secret" "observability_s3_user" {
  count = (local.enable_cortex || local.enable_loki || local.enable_tempo || local.enable_mimir) ? 1 : 0
  name  = "${local.cluster_name}-s3-user-secret-key"
}

resource "aws_secretsmanager_secret_version" "observability_s3_user" {
  count     = (local.enable_cortex || local.enable_loki || local.enable_tempo || local.enable_mimir) ? 1 : 0
  secret_id = aws_secretsmanager_secret.observability_s3_user.0.id
  secret_string = jsonencode({ username = aws_iam_user.observability_s3_user.0.name, access_key = aws_iam_access_key.observability_s3_user.0.user,
  access_secret = aws_iam_access_key.observability_s3_user.0.secret })
}

resource "kubernetes_service" "db_service" {
  count = try(local.grafana_enable && var.observability_config.grafana.persistence.type == "db" ? 1 : 0, 0)
  metadata {
    name      = "monitoring-rds"
    namespace = "db"
  }
  spec {
    type          = "ExternalName"
    external_name = split(":", module.rds[0].db_url)[0]
    port {
      port = module.rds[0].db_port
    }
  }
}