locals {
  ssl = var.sql_db != null ? (var.sql_db.enable_ssl == null ? false : var.sql_db.enable_ssl) : false

  sql_config_list = merge(
    { for service_key, service_val in var.services : 
        service_key => service_val.sql_config 
        if service_val.sql_config != null },
    { for cron_key, cron_val in var.cron_jobs : 
        cron_key => cron_val.sql_config 
        if cron_val.sql_config != null }
  )

  sqldb_list = flatten([
    for key, sql_config in local.sql_config_list : 
      sql_config.db_name != null ? [sql_config.db_name] : []
  ])

  db_map = local.sqldb_list != [] ? tomap({
    for service_key, sql_config in local.sql_config_list :
      "${var.namespace}-${sql_config.db_name}" => {
        master_db = var.namespace
        db_name   = sql_config.db_name
        user      = "${sql_config.db_name}_${random_string.db_username[sql_config.db_name].result}"
        sql_type  = sql_config.type  
      }
  }) : {}

  db_type = {
    mysql      = { port = 3306 }
    postgresql = { port = 5432 }
  }

}

data "google_sql_database_instance" "sql_instance" {
  for_each = local.sql_config_list

  name    = each.value.name
  project = var.provider_id
}

resource "random_string" "db_username" {
  length   = 6
  special  = false
  for_each = { for v in local.sqldb_list : v => v if v != null }
}

resource "google_sql_database" "sql_database" {
  for_each = {
    for service_key, sql_config in local.sql_config_list :
    service_key => sql_config
    if sql_config.db_name != null
  }
  name             = each.value.db_name
  project          = var.provider_id
  instance         = each.value.name
  charset          = "UTF8"
  collation        = each.value.db_collation != null ? each.value.db_collation : (each.value.type == "mysql" ? "utf8_general_ci" : "en_US.UTF8")
}

resource "kubernetes_secret" "db_init_script_create_role" {
  for_each    = local.db_map

  metadata {
    name      = "db-secret-${replace(each.key, "_" , "-")}"
    namespace = "db"
  }

  type = "Opaque"

  data = {
    "db-init.sql" = templatefile("${path.module}/templates/sql/${each.value.sql_type}-db-init-create-role-readonly.sql",
      {
        database            = each.value.db_name
        username            = each.value.user
        admin_user          = each.value.sql_type == "postgresql" ? "postgres" : "mysqladmin"
        db_password         = google_secret_manager_secret_version.db_editor_secret[each.key].secret_data
        db_readonlypassword = google_secret_manager_secret_version.readonly_db_secret[each.key].secret_data
      }
    )
  }
}

resource "kubectl_manifest" "postgres_db_init_create_db" {
  depends_on = [
    kubernetes_secret.db_init_script_create_role
  ]

  for_each = {
    for service_key, sql_config in local.sql_config_list :
    service_key => merge(
      sql_config,
      { rds_name = lookup({ for db_key, db_val in local.db_map : db_key => db_key }, "${var.namespace}-${sql_config.db_name}", null) }
    )
    if sql_config.type == "postgresql" && sql_config.db_name != null
  }

  yaml_body = templatefile("${path.module}/templates/sql/postgresql-db-init-job.yaml",
    {
      db_host            = data.google_sql_database_instance.sql_instance[each.key].private_ip_address
      db_name            = each.value.db_name
      db_user            = "postgres"
      db_port            = local.db_type[each.value.type].port
      namespace          = "db"
      rds_name           = replace(each.value.rds_name, "_" , "-")
      master_secret_name = "db-master-secret-${var.namespace}"
      name_prefix        = var.namespace
      enable_ssl         = each.value.enable_ssl
    }
  )
}

resource "kubectl_manifest" "db_init_create_db" {
  depends_on = [
    kubernetes_secret.db_init_script_create_role
  ]

  for_each = {
    for service_key, sql_config in local.sql_config_list :
    service_key => merge(
      sql_config,
      { rds_name = lookup({ for db_key, db_val in local.db_map : db_key => db_key }, "${var.namespace}-${sql_config.db_name}", null) }
    )
    if sql_config.type == "mysql" && sql_config.db_name != null
  }

  yaml_body = templatefile("${path.module}/templates/sql/mysql-db-init-job.yaml",
    {
      db_host            = data.google_sql_database_instance.sql_instance[each.key].private_ip_address
      db_name            = each.value.db_name
      db_user            = "mysqladmin"
      db_port            = local.db_type[each.value.type].port
      namespace          = "db"
      rds_name           = replace(each.value.rds_name, "_" , "-")
      master_secret_name = "db-master-secret-${var.namespace}"
      name_prefix        = var.namespace
      enable_ssl         = each.value.enable_ssl
    }
  )
}

resource "kubernetes_service" "sql_db_service" {
  for_each = local.sql_config_list != null ? local.sql_config_list : {}

  metadata {
    name      = "${var.namespace}-${each.key}-sql-config"
    namespace = "db"
  }

  spec {
    type          = "ExternalName"
    external_name = data.google_sql_database_instance.sql_instance[each.key].private_ip_address
    port {
      port = local.db_type[each.value.type].port
    }
  }
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
      "DB_NAME"         = lookup(local.sql_config_list, each.key, null) != null ? lookup(local.sql_config_list, each.key).db_name : (each.value.db_name != null ? each.value.db_name : null)
      "DB_USER"         = lookup(local.db_map, "${var.namespace}-${try(lookup(local.sql_config_list, each.key, {}).db_name, "")}", null) != null ? lookup(local.db_map, "${var.namespace}-${try(lookup(local.sql_config_list, each.key, {}).db_name, "")}").user : (try(each.value.db_name, "") != "" && length(module.sql_db) > 0 ? module.sql_db[0].db_user["${var.namespace}-${try(each.value.db_name, "")}"] : null)
      "DB_DIALECT"      = lookup(local.sql_config_list, each.key, null) != null ? (lookup(local.sql_config_list, each.key).type == "mysql" ? "mysql" : "postgres") : (each.value.db_name != null ? module.sql_db[0].db_type : null)
      "DB_HOST"         = lookup(local.sql_config_list, each.key, null) != null ? "${kubernetes_service.sql_db_service[each.key].metadata[0].name}.db" : (each.value.db_name != null ? "${var.namespace}-sql.db" : null)      
      "DB_PORT"         = lookup(local.sql_config_list, each.key, null) != null ? local.db_type[lookup(local.sql_config_list, each.key).type].port : (each.value.db_name != null ? module.sql_db[0].db_port : null)
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
      "DB_NAME"         = lookup(local.sql_config_list, each.key, null) != null ? lookup(local.sql_config_list, each.key).db_name : (each.value.db_name != null ? each.value.db_name : null)
      "DB_USER"         = lookup(local.db_map, "${var.namespace}-${try(lookup(local.sql_config_list, each.key, {}).db_name, "")}", null) != null ? lookup(local.db_map, "${var.namespace}-${try(lookup(local.sql_config_list, each.key, {}).db_name, "")}").user : (try(each.value.db_name, "") != "" && length(module.sql_db) > 0 ? module.sql_db[0].db_user["${var.namespace}-${try(each.value.db_name, "")}"] : null)
      "DB_DIALECT"      = lookup(local.sql_config_list, each.key, null) != null ? (lookup(local.sql_config_list, each.key).type == "mysql" ? "mysql" : "postgres") : (each.value.db_name != null ? module.sql_db[0].db_type : null)
      "DB_HOST"         = lookup(local.sql_config_list, each.key, null) != null ? "${kubernetes_service.sql_db_service[each.key].metadata[0].name}.db" : (each.value.db_name != null ? "${var.namespace}-sql.db" : null)      
      "DB_PORT"         = lookup(local.sql_config_list, each.key, null) != null ? local.db_type[lookup(local.sql_config_list, each.key).type].port : (each.value.db_name != null ? module.sql_db[0].db_port : null)
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