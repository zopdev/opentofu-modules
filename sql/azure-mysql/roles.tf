resource "kubernetes_secret" "mysql_db_init_script_master_password" {
  metadata {
    name      = "mysql-db-master-secret-${var.namespace}"
    namespace = "db"
  }

  type = "Opaque"

  data = {
    "password" = azurerm_key_vault_secret.mysql_db_secret.value
  }
}

resource "kubernetes_secret" "mysql_db_init_script_create_role" {
  for_each = local.db_map

  metadata {
    name      = "mysql-db-secret-${replace(each.key, "_" , "-")}"
    namespace = "db"
  }

  type = "Opaque"

  data = {
    "db-init.sql" = templatefile("${path.module}/templates/mysql-init-create-role-readonly.sql",
      {
        database            = each.value.db_name
        username            = each.value.user
        admin_user          = var.administrator_login
        db_password         = azurerm_key_vault_secret.mysql_db_editor_secret[each.key].value
        db_readonlypassword = azurerm_key_vault_secret.mysql_db_readonly_secret[each.key].value
      }
    )
  }
}

resource "kubectl_manifest" "db_init_create_db" {
  depends_on = [
    kubernetes_secret.mysql_db_init_script_master_password,
    kubernetes_secret.mysql_db_init_script_create_role
  ]

  for_each  = local.db_map
  yaml_body = templatefile("${path.module}/templates/mysql-db-init-job.yaml",
    {
      db_host            = azurerm_mysql_flexible_server.mysql_server.fqdn
      db_name            = each.value.db_name
      db_user            = var.administrator_login
      db_port            = 3306
      namespace          = "db"
      rds_name           = "mysql-db-secret-${replace(each.key, "_" , "-")}"
      master_secret_name = "mysql-db-master-secret-${var.namespace}"
    }
  )
}
