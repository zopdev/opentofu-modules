resource "kubernetes_config_map" "psql_db_init_script_create_db" {
  for_each = var.rds_type == "postgresql" ? local.db_map : {}

  metadata {
    name      = "postgresql-db-config-${each.key}-create-db"
    namespace = "db"
  }

  data = {
    "db-init.sql" = templatefile("${path.module}/templates/postgresql-db-init-create-database.sql",
      {
        database = each.value.db_name
      }
    )
  }
}

resource "kubernetes_config_map" "mysql_db_init_script_create_db" {
  for_each = var.rds_type == "mysql" ? local.db_map : {}

  metadata {
    name      = "mysql-db-config-${each.key}-create-db"
    namespace = "db"
  }

  data = {
    "db-init.sql" = templatefile("${path.module}/templates/mysql-db-init-create-database.sql",
      {
        database = each.value.db_name
      }
    )
  }
}

resource "kubernetes_secret" "db_init_script_master_password" {

  metadata {
    name      = "db-master-secret-${var.namespace}"
    namespace = "db"
  }

  type = "Opaque"

  data = {
    "password" = aws_secretsmanager_secret_version.db_secret.secret_string
  }

}

resource "kubernetes_secret" "psql_db_init_script_create_role" {
  for_each = var.rds_type == "postgresql" ? local.db_map : {}

  metadata {
    name      = "postgresql-db-secret-${replace(each.key, "_" , "-")}"
    namespace = "db"
  }

  type = "Opaque"

  data = {
    "db-init.sql" = templatefile("${path.module}/templates/postgresql-db-init-create-role-readonly.sql",
      {
        database            = each.value.db_name
        username            = each.value.user
        admin_user          = var.admin_user
        db_password         = aws_secretsmanager_secret_version.db_editor_secret[each.key].secret_string
        db_readonlypassword = aws_secretsmanager_secret_version.readonly_db_secret[each.key].secret_string
      }
    )
  }
}

resource "kubernetes_secret" "mysql_db_init_script_create_role" {
  for_each = var.rds_type == "mysql" ? local.db_map : {}

  metadata {
    name      = "mysql-db-secret-${replace(each.key, "_" , "-")}"
    namespace = "db"
  }

  type = "Opaque"

  data = {
    "db-init.sql" = templatefile("${path.module}/templates/mysql-db-init-create-role-readonly.sql",
      {
        database            = each.value.db_name
        username            = each.value.user
        admin_user          = var.admin_user
        db_password         = aws_secretsmanager_secret_version.db_editor_secret[each.key].secret_string
        db_readonlypassword = aws_secretsmanager_secret_version.readonly_db_secret[each.key].secret_string
      }
    )
  }
}

resource "kubectl_manifest" "psql_db_init_create_db" {
  depends_on = [
    kubernetes_config_map.psql_db_init_script_create_db,
    kubernetes_secret.db_init_script_master_password,
    kubernetes_secret.psql_db_init_script_create_role
  ]

  for_each = var.rds_type == "postgresql" ? local.db_map : {}
  yaml_body = templatefile("${path.module}/templates/postgresql-db-init-job.yaml",
    {
      db_host            = split(":", aws_db_instance.db_instance.endpoint)[0]
      db_name            = each.value.db_name
      db_user            = aws_db_instance.db_instance.username
      db_port            = aws_db_instance.db_instance.port
      namespace          = "db"
      rds_name           = replace(each.key, "_" , "-")
      master_secret_name = "db-master-secret-${each.value.master_db}"
    }
  )
}

resource "kubectl_manifest" "mysql_db_init_create_db" {
  depends_on = [
    kubernetes_config_map.mysql_db_init_script_create_db,
    kubernetes_secret.db_init_script_master_password,
    kubernetes_secret.mysql_db_init_script_create_role
  ]

  for_each = var.rds_type == "mysql" ? local.db_map : {}
  yaml_body = templatefile("${path.module}/templates/mysql-db-init-job.yaml",
    {
      db_host            = split(":", aws_db_instance.db_instance.endpoint)[0]
      db_name            = each.value.db_name
      db_user            = aws_db_instance.db_instance.username
      db_port            = aws_db_instance.db_instance.port
      namespace          = "db"
      rds_name           = replace(each.key, "_" , "-")
      master_secret_name = "db-master-secret-${each.value.master_db}"
    }
  )
}
