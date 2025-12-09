locals {
  ssl          = var.sql_db != null ? (var.sql_db.enable_ssl == null ? false : var.sql_db.enable_ssl) : false
  postgres_ssl = try(var.sql_db != null && var.sql_db.type == "postgresql" ? (var.sql_db.enable_ssl == null ? false : var.sql_db.enable_ssl) : false, false)
}

resource "kubernetes_config_map" "namespace_configs" {
  metadata {
    name      = var.namespace
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }

  data = {
    "CLOUD"  = "Azure"
    "DB_SSL" = local.postgres_ssl ? "require" : null
  }
}

resource "kubernetes_config_map" "service_configs" {
  for_each = { for k, v in var.services : k => v }
  metadata {
    name      = "${each.key}-infra"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }

  data = merge(
    {
      "APP_NAME"   = each.key
      "DB_NAME"    = each.value.db_name != null ? each.value.db_name : each.value.datastore_configs != null ? each.value.datastore_configs.databse : null
      "DB_USER"    = each.value.db_name != null ? var.sql_db.type == "mysql" ? module.mysql[0].db_user["${var.namespace}-${each.value.db_name}"] : module.postgresql[0].db_user["${var.namespace}-${each.value.db_name}"] : each.value.datastore_configs != null ? each.value.datastore_configs.type == "mysql" ? module.mysql_v2[each.value.datastore_configs.name].db_user["${var.namespace}-${each.value.datastore_configs.databse}"] : module.postgres_v2[each.value.datastore_configs.name].db_user["${var.namespace}-${each.value.datastore_configs.databse}"] : null
      "DB_DIALECT" = each.value.db_name != null ? (var.sql_db.type == "mysql" ? "mysql" : "postgres") : each.value.datastore_configs != null ? (each.value.datastore_configs.type == "mysql" ? "mysql" : "postgres") : null
      "DB_HOST"    = each.value.db_name != null ? "${var.namespace}-sql.db" : each.value.datastore_configs != null ? "${each.value.datastore_configs.name}-sql.db" : null
      "DB_PORT"    = each.value.db_name != null ? var.sql_db.type == "mysql" ? module.mysql[0].db_port : module.postgresql[0].db_port : each.value.datastore_configs != null ? each.value.datastore_configs.type == "mysql" ? module.mysql_v2[each.value.datastore_configs.name].db_port : module.postgres_v2[each.value.datastore_configs.name].db_port : null
      "REDIS_HOST" = each.value.redis == true || each.value.local_redis == true ? (each.value.redis == true ? "${var.namespace}-redis" : "redis-master-master") : (each.value.redis_configs != null ? "${each.value.redis_configs.name}-${var.namespace}-redis" : null),
      "REDIS_PORT" = each.value.redis == true || each.value.local_redis == true ? "6379" : (each.value.redis_configs != null ? each.value.redis_configs.port : null)
  })
}

resource "kubernetes_config_map" "cron_jobs_configs" {
  for_each = { for k, v in var.cron_jobs : k => v }
  metadata {
    name      = "${each.key}-infra"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }

  data = merge(
    {
      "APP_NAME"   = each.key
      "DB_NAME"    = each.value.db_name != null ? each.value.db_name : each.value.datastore_configs != null ? each.value.datastore_configs.databse : null
      "DB_USER"    = each.value.db_name != null ? var.sql_db.type == "mysql" ? module.mysql[0].db_user["${var.namespace}-${each.value.db_name}"] : module.postgresql[0].db_user["${var.namespace}-${each.value.db_name}"] : each.value.datastore_configs != null ? each.value.datastore_configs.type == "mysql" ? module.mysql_v2[each.value.datastore_configs.name].db_user["${var.namespace}-${each.value.datastore_configs.databse}"] : module.postgres_v2[each.value.datastore_configs.name].db_user["${var.namespace}-${each.value.datastore_configs.databse}"] : null
      "DB_DIALECT" = each.value.db_name != null ? (var.sql_db.type == "mysql" ? "mysql" : "postgres") : each.value.datastore_configs != null ? (each.value.datastore_configs.type == "mysql" ? "mysql" : "postgres") : null
      "DB_HOST"    = each.value.db_name != null ? "${var.namespace}-sql.db" : each.value.datastore_configs != null ? "${each.value.datastore_configs.name}-sql.db" : null
      "DB_PORT"    = each.value.db_name != null ? var.sql_db.type == "mysql" ? module.mysql[0].db_port : module.postgresql[0].db_port : each.value.datastore_configs != null ? each.value.datastore_configs.type == "mysql" ? module.mysql_v2[each.value.datastore_configs.name].db_port : module.postgres_v2[each.value.datastore_configs.name].db_port : null
      "REDIS_HOST" = each.value.redis == true || each.value.local_redis == true ? (each.value.redis == true ? "${var.namespace}-redis" : "redis-master-master") : (each.value.redis_configs != null ? "${each.value.redis_configs.name}-${var.namespace}-redis" : null),
      "REDIS_PORT" = each.value.redis == true || each.value.local_redis == true ? "6379" : (each.value.redis_configs != null ? each.value.redis_configs.port : null)
  })
}

resource "kubernetes_config_map" "env_service_configmap" {
  for_each = var.services

  metadata {
    name      = each.key
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }
  lifecycle {
    ignore_changes = [data, metadata[0].annotations, metadata[0].labels]
  }
}

resource "kubernetes_config_map" "env_cron_configmap" {
  for_each = var.cron_jobs

  metadata {
    name      = each.key
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }
  lifecycle {
    ignore_changes = [data, metadata[0].annotations, metadata[0].labels]
  }
}