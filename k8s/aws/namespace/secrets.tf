locals {
}

# Service account with access to fetch the AWS secrets in all environment namespace
resource "kubernetes_service_account" "secrets" {
  metadata {
    name      = "secrets-account"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_admin.this_iam_role_arn
    }
  }
}

# Adds the secrets provider for the secrets initialized for the namespace
resource "kubectl_manifest" "secrets_provider" {
  for_each = { for k, v in var.services : k => v }

  yaml_body = templatefile("${path.module}/templates/secret-provider-class.yaml",
    {
      secrets = jsonencode(concat(
        (each.value.db_name != null ? [{ key = "DB_PASSWORD", value = "${local.cluster_name}-${var.namespace}-${each.value.db_name}-db-secret" }] : []),
        (each.value.datastore_configs != null ? [{ key = "DB_PASSWORD", value = "${local.cluster_name}-${var.namespace}-${each.value.datastore_configs.databse}-db-secret" }] : []),
        #        var.cassandra_db == null ? [] : ["${local.cluster_name}-${var.namespace}-cassandra-secret"],
        try([for secret in each.value.custom_secrets : { key = secret, value = "${local.cluster_name}-${var.namespace}-${each.key}-${secret}-secret" }], []),
        try([for ns in var.custom_namespace_secrets : { key = ns, value = "${local.cluster_name}-${var.namespace}-${ns}-secret" }], []),
        length(var.dynamo_db) == 0 ? [] : ["${local.cluster_name}-${var.namespace}-dynamo-user-secret-key"],
        #        can(var.kafka[var.namespace].topics)== true ? (length(var.kafka[var.namespace].topics) > 0 ? ["${local.cluster_name}-msk-secret"] : []) : []
      ))
      namespace    = kubernetes_namespace.app_environments.metadata[0].name
      service_name = each.key
    }
  )
}

# Adds the secrets provider for the secrets initialized for the namespace
resource "kubectl_manifest" "secrets_provider_cron_jobs" {
  for_each = { for k, v in var.cron_jobs : k => v }

  yaml_body = templatefile("${path.module}/templates/secret-provider-class.yaml",
    {
      secrets = jsonencode(concat(
        (each.value.db_name != null ? [{ key = "DB_PASSWORD", value = "${local.cluster_name}-${var.namespace}-${each.value.db_name}-db-secret" }] : []),
        (each.value.datastore_configs != null ? [{ key = "DB_PASSWORD", value = "${local.cluster_name}-${var.namespace}-${each.value.datastore_configs.databse}-db-secret" }] : []),
        #        var.cassandra_db == null ? [] : ["${local.cluster_name}-${var.namespace}-cassandra-secret"],
        try([for secret in each.value.custom_secrets : { key = secret, value = "${local.cluster_name}-${var.namespace}-${each.key}-${secret}-secret" }], []),
        try([for ns in var.custom_namespace_secrets : { key = ns, value = "${local.cluster_name}-${var.namespace}-${ns}-secret" }], []),
        length(var.dynamo_db) == 0 ? [] : ["${local.cluster_name}-${var.namespace}-dynamo-user-secret-key"],
        #        can(var.kafka[var.namespace].topics)== true ? (length(var.kafka[var.namespace].topics) > 0 ? ["${local.cluster_name}-msk-secret"] : []) : []
      ))
      namespace    = kubernetes_namespace.app_environments.metadata[0].name
      service_name = each.key
    }
  )
}

resource "random_password" "cassandra_password" {
  count   = var.cassandra_db == null ? 0 : 1
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "cassandra_secret" {
  count = var.cassandra_db == null ? 0 : 1
  name  = "${local.cluster_name}-${var.namespace}-cassandra-secret"
  tags  = local.common_tags
}

resource "aws_secretsmanager_secret_version" "cassandra_secret" {
  count         = var.cassandra_db == null ? 0 : 1
  secret_id     = aws_secretsmanager_secret.cassandra_secret[0].id
  secret_string = random_password.cassandra_password[0].result
}
