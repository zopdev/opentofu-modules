data "aws_secretsmanager_secrets" "kafka_secert" {
  filter {
    name   = "name"
    values = ["AmazonMSK_events-framework-${var.app_env}-secret"]
  }
}


data "aws_secretsmanager_secret" "kafka_secert_msk" {
  count = length(data.aws_secretsmanager_secrets.kafka_secert.arns) == 0 ? 0 : 1
  arn   = one(data.aws_secretsmanager_secrets.kafka_secert.arns)
}


data "aws_secretsmanager_secret_version" "kafka_secert_version" {
  count     = length(data.aws_secretsmanager_secrets.kafka_secert.arns) == 0 ? 0 : 1
  secret_id = data.aws_secretsmanager_secret.kafka_secert_msk[0].id
}

resource "aws_secretsmanager_secret" "local_kafka" {
  count = length(data.aws_secretsmanager_secrets.kafka_secert.arns) == 0 ? 0 : 1
  name  = "${local.cluster_name}-msk-secret"
  tags  = local.common_tags
}

resource "aws_secretsmanager_secret_version" "local_kafka" {
  count         = length(data.aws_secretsmanager_secrets.kafka_secert.arns) == 0 ? 0 : 1
  secret_id     = aws_secretsmanager_secret.local_kafka[0].id
  secret_string = jsondecode(data.aws_secretsmanager_secret_version.kafka_secert_version[0].secret_string).password
}