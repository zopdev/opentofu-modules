locals {
  ssl = try(
    var.sql_list != null ? 
      anytrue([for k, v in var.sql_list : lookup(v, "enable_ssl", false)]) : 
      false,
    false
  )
}

resource "kubernetes_config_map" "namespace_configs" {
  metadata {
    name      = var.namespace
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }

  data = {
    "CLOUD"                  = "GCP"
    "DB_SSL"                 = local.ssl ? "require" : null
    "DB_CERTIFICATE_FILE"    = local.ssl ? "/etc/ssl/client.pem" : null
    "DB_KEY_FILE"            = local.ssl ? "/etc/ssl/private.pem" : null
  }
}

resource "kubernetes_config_map" "service_configs" {
  for_each = {for k, v in var.services : k => v}
  metadata {
    name      = "${each.key}-infra"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }
  data = merge(
    {
      "APP_NAME"    = each.key
      "DB_NAME"     = each.value.datastore_configs != null ? each.value.datastore_configs.database : null
      "DB_USER"     = each.value.datastore_configs != null ? (
                        each.value.datastore_configs.type == "mysql" ? 
                          module.sql_db[each.value.datastore_configs.name].db_user["${var.namespace}-${each.value.datastore_configs.database}"] : 
                          module.psql_db[each.value.datastore_configs.name].db_user["${var.namespace}-${each.value.datastore_configs.database}"]
                      ) : null
      "DB_DIALECT"  = each.value.datastore_configs != null ? (
                        each.value.datastore_configs.type == "mysql" ? "mysql" : "postgres"
                      ) : null
      "DB_HOST"     = each.value.datastore_configs != null ? (
                        each.value.datastore_configs.type == "mysql" ? 
                          "${each.value.datastore_configs.name}-sql.db" : 
                          "${each.value.datastore_configs.name}-psql.db"
                      ) : null
      "DB_PORT"     = each.value.datastore_configs != null ? (
                        each.value.datastore_configs.type == "mysql" ? 
                          module.sql_db[each.value.datastore_configs.name].db_port : 
                          module.psql_db[each.value.datastore_configs.name].db_port
                      ) : null
      "REDIS_HOST"  = each.value.redis_configs != null ? "${each.value.redis_configs.name}-${var.namespace}-redis" : null,
      "REDIS_PORT"  = each.value.redis_configs != null ? each.value.redis_configs.port : null
    }
  )
}

resource "kubernetes_config_map" "cron_jobs_configs" {
  for_each = {for k, v in var.cron_jobs : k => v}
  metadata {
    name      = "${each.key}-infra"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }
  data = merge(
    {
      "APP_NAME"    = each.key
      "DB_NAME"     = each.value.datastore_configs != null ? each.value.datastore_configs.database : null
      "DB_USER"     = each.value.datastore_configs != null ? (
                        each.value.datastore_configs.type == "mysql" ? 
                          module.sql_db[each.value.datastore_configs.name].db_user["${var.namespace}-${each.value.datastore_configs.database}"] : 
                          module.psql_db[each.value.datastore_configs.name].db_user["${var.namespace}-${each.value.datastore_configs.database}"]
                      ) : null
      "DB_DIALECT"  = each.value.datastore_configs != null ? (
                        each.value.datastore_configs.type == "mysql" ? "mysql" : "postgres"
                      ) : null
      "DB_HOST"     = each.value.datastore_configs != null ? (
                        each.value.datastore_configs.type == "mysql" ? 
                          "${each.value.datastore_configs.name}-sql.db" : 
                          "${each.value.datastore_configs.name}-psql.db"
                      ) : null
      "DB_PORT"     = each.value.datastore_configs != null ? (
                        each.value.datastore_configs.type == "mysql" ? 
                          module.sql_db[each.value.datastore_configs.name].db_port : 
                          module.psql_db[each.value.datastore_configs.name].db_port
                      ) : null
      "REDIS_HOST"  = each.value.redis_configs != null ? "${each.value.redis_configs.name}-${var.namespace}-redis" : null,
      "REDIS_PORT"  = each.value.redis_configs != null ? each.value.redis_configs.port : null
    })
}

resource "kubernetes_config_map" "env_service_configmap" {
  for_each  = var.services

  metadata {
    name      = each.key
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }
  lifecycle {
    ignore_changes = [data, metadata[0].annotations, metadata[0].labels]
  }
}

resource "kubernetes_config_map" "env_cron_configmap" {
  for_each  = var.cron_jobs

  metadata {
    name      = each.key
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }
  lifecycle {
    ignore_changes = [data, metadata[0].annotations, metadata[0].labels]
  }
}