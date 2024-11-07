resource "aws_secretsmanager_secret" "msk_secret" {
  name       = "AmazonMSK_${var.kafka_cluster_name}-secret"
  kms_key_id = aws_kms_key.msk_kms_key.key_id

  tags = local.common_tags
}

resource "aws_kms_key" "msk_kms_key" {
  description = "Key for MSK Cluster Scram Secret Association"

  tags = local.common_tags
}

resource "random_password" "scram_password" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret_version" "msk_secret" {
  secret_id     = aws_secretsmanager_secret.msk_secret.id
  secret_string = jsonencode({ username = var.kafka_admin_user, password = random_password.scram_password.result,
    kafka_host = aws_msk_cluster.msk_cluster.bootstrap_brokers_sasl_scram })
}

resource "aws_secretsmanager_secret_policy" "msk_secret_policy" {
  secret_arn = aws_secretsmanager_secret.msk_secret.arn
  policy     = <<POLICY
{
  "Version" : "2012-10-17",
  "Statement" : [ {
    "Sid": "AWSKafkaResourcePolicy",
    "Effect" : "Allow",
    "Principal" : {
      "Service" : "kafka.amazonaws.com"
    },
    "Action" : "secretsmanager:getSecretValue",
    "Resource" : "${aws_secretsmanager_secret.msk_secret.arn}"
  } ]
}
POLICY
}
