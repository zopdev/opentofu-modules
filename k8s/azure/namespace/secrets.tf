data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "secrets" {
  name = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].azurerm_key_vault_name : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].azurerm_key_vault_name : module.remote_state_azure_cluster[0].azurerm_key_vault_name)
  resource_group_name = var.resource_group_name
}

resource "random_password" "cassandra_password" {
  count    = var.cassandra_db == null ? 0 : 1
  length   = 16
  special  = false
}

resource "azurerm_key_vault_secret" "cassandra_secret" {
  count                 = var.cassandra_db == null ? 0 : 1
  name                  = "cassandra-secret"
  value                 = random_password.cassandra_password[0].result
  key_vault_id          = data.azurerm_key_vault.secrets.id
}

# Adds the secrets provider for the secrets initialized for the particular cluster in all namespaces
resource "kubectl_manifest" "secrets_provider" {
  for_each = { for k,v in var.services : k => v }

  yaml_body = templatefile("${path.module}/templates/secret-provider-class.yaml",
    {
      secrets = jsonencode(concat(
        (each.value.db_name != null ? ( var.sql_db != null ? (var.sql_db.type == "mysql" ?
          [{ key = "DB_PASSWORD" , value = "${local.cluster_name}-${var.namespace}-${replace(each.value.db_name,"_","-")}-mysql-db-secret" }] :
          [{ key = "DB_PASSWORD" , value = "${local.cluster_name}-${var.namespace}-${replace(each.value.db_name,"_","-")}-postgres-db-secret" }]) : []) : []),
        (each.value.redis == true ? [{ key = "REDIS_PASSWORD" , value = "${local.cluster_name}-${var.namespace}-redis-secret" }] : []),
        try([for ns in var.custom_namespace_secrets[var.namespace].secrets : { key = ns, value = "${local.cluster_name}-${var.namespace}-${ns}-secret"}], []),
        try([for secret in each.value.custom_secrets  : { key = secret, value = strcontains(secret, "_") ? "${local.cluster_name}-${var.namespace}-${each.key}-${replace(secret, "_", "-underscore-")}-secret"  : "${local.cluster_name}-${var.namespace}-${each.key}-${secret}-secret"}], []),
      ))
      namespace    = kubernetes_namespace.app_environments.metadata[0].name
      service_name = each.key
      keyvaultname = data.azurerm_key_vault.secrets.name
      tenantId     = data.azurerm_client_config.current.tenant_id
    }
  )
}

### Adds the secrets provider for the secrets initialized for the particular cluster in all namespace
resource "kubectl_manifest" "secrets_provider_cron_jobs" {
  for_each = { for k,v in var.cron_jobs : k => v }

  yaml_body = templatefile("${path.module}/templates/secret-provider-class.yaml",
    {
      secrets = jsonencode(concat(
        (each.value.db_name != null ? ( var.sql_db != null ? (var.sql_db.type == "mysql" ?
        [{ key = "DB_PASSWORD" , value = "${local.cluster_name}-${var.namespace}-${replace(each.value.db_name,"_","-")}-mysql-db-secret" }] :
        [{ key = "DB_PASSWORD" , value = "${local.cluster_name}-${var.namespace}-${replace(each.value.db_name,"_","-")}-postgres-db-secret" }]) : []) : []),
        (each.value.redis == true ? [{ key = "REDIS_PASSWORD" , value = "${local.cluster_name}-${var.namespace}-redis-secret" }] : []),
        try([for ns in var.custom_namespace_secrets[var.namespace].secrets : { key = ns, value = "${local.cluster_name}-${var.namespace}-${ns}-secret"}], []),
        try([for secret in each.value.custom_secrets  : { key = secret, value = strcontains(secret, "_") ? "${local.cluster_name}-${var.namespace}-${each.key}-${replace(secret, "_", "-underscore-")}-secret"  : "${local.cluster_name}-${var.namespace}-${each.key}-${secret}-secret"}], []),
      ))
      namespace    = kubernetes_namespace.app_environments.metadata[0].name
      service_name = each.key
      keyvaultname = data.azurerm_key_vault.secrets.name
      tenantId     = data.azurerm_client_config.current.tenant_id
    }
  )
}

# Service account with access to fetch the Azure secrets in all environment namespaces
resource "kubernetes_service_account" "secrets" {
  metadata {
    name      = "secrets-account"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }
}