locals {
  ssl = var.sql_db != null ? (var.sql_db.enable_ssl == null ? false : var.sql_db.enable_ssl) : false
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
    "DB_CA_CERTIFICATE_FILE" = local.ssl ? (var.sql_db.type == "mysql" ? "/etc/ssl/server.pem" : null) : null
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
      "PUBSUB_BACKEND"         = each.value.pub_sub != null ? "GOOGLE" : null
      "GOOGLE_PROJECT_ID"      = each.value.pub_sub != null ? var.provider_id : null
      "APP_NAME"        = each.key
      "DB_NAME"         = each.value.db_name != null ? each.value.db_name : null
      "DB_USER"         = each.value.db_name != null ? module.sql_db[0].db_user["${var.namespace}-${each.value.db_name}"] : null
      "DB_DIALECT"      = each.value.db_name != null ? module.sql_db[0].db_type : null
      "DB_HOST"         = each.value.db_name != null ? "${var.namespace}-sql.db" : null
      "DB_PORT"         = each.value.db_name != null ? module.sql_db[0].db_port : null
      "REDIS_HOST"      = each.value.redis == true || each.value.local_redis == true ? (each.value.redis == true ? "${var.namespace}-redis" : (each.value.local_redis == true ? "redis-master-master" : null)): null
      "REDIS_PORT"      = each.value.redis == true || each.value.local_redis == true ? "6379" : null
    })
}


resource "kubernetes_config_map" "cron_jobs_configs" {
  for_each = {for k, v in var.cron_jobs : k => v}
  metadata {
    name      = "${each.key}-infra"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }
  data = merge(
    {
      "PUBSUB_BACKEND"         = each.value.pub_sub != null ? "GOOGLE" : null
      "GOOGLE_PROJECT_ID"      = each.value.pub_sub != null ? var.provider_id : null
      "APP_NAME"        = each.key
      "DB_NAME"         = each.value.db_name != null ? each.value.db_name : null
      "DB_USER"         = each.value.db_name != null ? module.sql_db[0].db_user["${var.namespace}-${each.value.db_name}"] : null
      "DB_DIALECT"      = each.value.db_name != null ? module.sql_db[0].db_type : null
      "DB_HOST"         = each.value.db_name != null ? "${var.namespace}-sql.db" : null
      "DB_PORT"         = each.value.db_name != null ? module.sql_db[0].db_port : null
      "REDIS_HOST"      = each.value.redis == true || each.value.local_redis == true ? (each.value.redis == true ? "${var.namespace}-redis" : (each.value.local_redis == true ? "redis-master-master" : null)): null
      "REDIS_PORT"      = each.value.redis == true || each.value.local_redis == true ? "6379" : null
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