resource "kubernetes_secret" "db_init_script_master_password" {

  metadata {
    name      = var.multi_ds ? "db-master-secret-${var.namespace}-${var.sql_name}" : "db-master-secret-${var.namespace}"
    namespace = "db"
  }

  type = "Opaque"

  data = {
    "password" = google_secret_manager_secret_version.db_secret.secret_data
  }
}

resource "kubernetes_secret" "db_init_script_create_role" {
  for_each    = local.db_map

  metadata {
    name      = "db-secret-${replace(each.key, "_" , "-")}"
    namespace = "db"
  }

  type = "Opaque"

  data = {
    "db-init.sql" = templatefile("${path.module}/templates/${var.sql_type}-db-init-create-role-readonly.sql",
      {
        database            = each.value.db_name
        username            = each.value.user
        admin_user          = var.sql_type == "postgresql" ? "postgres" : "mysqladmin"
        db_password         = google_secret_manager_secret_version.db_editor_secret[each.key].secret_data
        db_readonlypassword = google_secret_manager_secret_version.readonly_db_secret[each.key].secret_data
      }
    )
  }
}

resource "kubectl_manifest" "postgres_db_init_create_db" {
  depends_on = [
    google_sql_database.sql_database,
    kubernetes_secret.db_init_script_master_password,
    kubernetes_secret.db_init_script_create_role,
    kubernetes_secret.ssl_certs
  ]

  for_each  = var.sql_type == "postgresql" ? local.db_map : {}
  yaml_body = templatefile("${path.module}/templates/postgresql-db-init-job.yaml",
    {
      db_host            = google_sql_database_instance.postgres_sql_db[0].private_ip_address
      db_name            = each.value.db_name
      db_user            = "postgres"
      db_port            = local.db_type[var.sql_type].port
      namespace          = "db"
      rds_name           = replace(each.key, "_" , "-")
      master_secret_name = var.multi_ds ? "db-master-secret-${var.namespace}-${var.sql_name}" : "db-master-secret-${var.namespace}"
      name_prefix        = var.namespace
      enable_ssl         = var.enable_ssl
    }
  )
}

resource "kubectl_manifest" "db_init_create_db" {
  depends_on = [
    google_sql_database.sql_database,
    kubernetes_secret.db_init_script_master_password,
    kubernetes_secret.db_init_script_create_role,
    kubernetes_secret.ssl_certs
  ]

  for_each  = var.sql_type == "mysql" ? local.db_map : {}
  yaml_body = templatefile("${path.module}/templates/mysql-db-init-job.yaml",
    {
      db_host            = google_sql_database_instance.sql_db[0].private_ip_address
      db_name            = each.value.db_name
      db_user            = "mysqladmin"
      db_port            = local.db_type[var.sql_type].port
      namespace          = "db"
      rds_name           = replace(each.key, "_" , "-")
      master_secret_name = var.multi_ds ? "db-master-secret-${var.namespace}-${var.sql_name}" : "db-master-secret-${var.namespace}"
      name_prefix        = var.namespace
      enable_ssl         = var.enable_ssl
    }
  )
}

resource "kubernetes_secret" "ssl_certs" {
  count = var.enable_ssl  ? 1 : 0
  metadata {
    name      = "${var.namespace}-ssl-certs"
    namespace = "db"
  }

  type = "Opaque"

  data = {
    "server.pem"  = var.sql_type == "postgresql" ? google_sql_ssl_cert.postgresql_db_cert[0].server_ca_cert : google_sql_ssl_cert.sql_db_cert[0].server_ca_cert
    "client.pem"  = var.sql_type == "postgresql" ? google_sql_ssl_cert.postgresql_db_cert[0].cert : google_sql_ssl_cert.sql_db_cert[0].cert
    "private.pem" = var.sql_type == "postgresql" ? google_sql_ssl_cert.postgresql_db_cert[0].private_key : google_sql_ssl_cert.sql_db_cert[0].private_key
  }
}

resource "kubernetes_secret" "namespace_ssl_certs" {
  count = var.enable_ssl ? 1 : 0
  metadata {
    name      = "ssl-certs"
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    "server.pem"  = var.sql_type == "postgresql" ? google_sql_ssl_cert.postgresql_db_cert[0].server_ca_cert : google_sql_ssl_cert.sql_db_cert[0].server_ca_cert
    "client.pem"  = var.sql_type == "postgresql" ? google_sql_ssl_cert.postgresql_db_cert[0].cert : google_sql_ssl_cert.sql_db_cert[0].cert
    "private.pem" = var.sql_type == "postgresql" ? google_sql_ssl_cert.postgresql_db_cert[0].private_key : google_sql_ssl_cert.sql_db_cert[0].private_key
  }
}
