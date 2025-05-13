locals {
  custom_secrets = merge([
    for k in keys(var.services) : tomap({
      for secret in var.services[k].custom_secrets : "${k}-${secret}" => {
        secret_name = secret
        service     = k
      }
    }) if var.services[k].custom_secrets != null
  ]...)

  cron_job_custom_secrets = merge([
    for k in keys(var.cron_jobs) : tomap({
      for secret in var.cron_jobs[k].custom_secrets : "${k}-${secret}" => {
        secret_name = secret
        cron_job    = k
      }
    }) if var.cron_jobs[k].custom_secrets != null
  ]...)
}

resource "kubernetes_service_account" "secrets" {
  metadata {
    name      = "secrets-account"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
    annotations = {
      "oci.oraclecloud.com/sa-token-secret-name" = "oke-sa-token"
    }
  }
}

resource "kubectl_manifest" "secrets_provider" {
  for_each = { for k,v in var.services : k => v }
  
  yaml_body = templatefile("${path.module}/templates/secret-provider-class.yaml",
    {
      secrets = jsonencode(concat(
        (each.value.datastore_configs != null ? [{ 
          key = "DB_PASSWORD", 
          value = "${each.value.datastore_configs.name}-${var.namespace}-${replace(each.value.datastore_configs.database,"_","-")}-${each.value.datastore_configs.type == "mysql" ? "mysql-db" : "postgres-db"}" 
        }] : []),
        try([for secret in each.value.custom_secrets : { key = secret, value = "${local.cluster_name}-${var.namespace}-${each.key}-${secret}-secret"}], []),
      ))
      namespace    = kubernetes_namespace.app_environments.metadata[0].name
      service_name = each.key
      vault_ocid   = module.remote_state_oci_cluster.0.kms_vault_id
    }
  )
}

resource "kubectl_manifest" "secrets_provider_cron_jobs" {
  for_each = { for k,v in var.cron_jobs : k => v }

  yaml_body = templatefile("${path.module}/templates/secret-provider-class.yaml",
    {
      secrets = jsonencode(concat(
        (each.value.datastore_configs != null ? [{ 
          key = "DB_PASSWORD", 
          value = "${each.value.datastore_configs.name}-${var.namespace}-${replace(each.value.datastore_configs.database,"_","-")}-${each.value.datastore_configs.type == "mysql" ? "mysql-db" : "postgres-db"}" 
        }] : []),
        try([for secret in each.value.custom_secrets  : { key = secret, value = "${local.cluster_name}-${var.namespace}-${each.key}-${secret}-secret"}], []),
      ))
      namespace    = kubernetes_namespace.app_environments.metadata[0].name
      service_name = each.key
      vault_ocid   = module.remote_state_oci_cluster.0.kms_vault_id
    }
  )
}


