locals {
  db_map = tomap({
    for database in var.databases : "${var.namespace}-${database}" => {
      master_db = var.namespace
      db_name   = database
      user = "${database}_${random_string.mysql_username[database].result}"
    } if database != null
  })
}

resource "random_password" "mysql_db_password" {
  length         = 16
  special        = true
}

resource "random_string" "mysql_username" {
  length   = 6
  special  = false
  for_each = {for v in var.databases : v => v if v != null}
}

resource "random_string" "mysql_editor_password" {
  length   = 16
  special  = false
  for_each = local.db_map
}

resource "random_string" "mysql_reader_password" {
  length   = 16
  special  = false
  for_each = local.db_map
}

resource "azurerm_key_vault_secret" "mysql_db_secret" {
  name         = "${var.cluster_name}-${var.namespace}-${var.mysql_server_name}-mysql-db-secret"
  value        = random_password.mysql_db_password.result
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "mysql_db_user_secret" {
  for_each     = local.db_map
  name         = "${var.cluster_name}-${replace(each.key,"_","-")}-mysql-db-user-secret"
  value        = each.value.user
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "mysql_db_editor_secret" {
  for_each     = local.db_map
  name         = "${var.cluster_name}-${replace(each.key,"_","-")}-mysql-db-secret"
  value        = random_string.mysql_editor_password[each.key].result
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "mysql_db_readonly_secret" {
  for_each     = local.db_map
  name         = "${var.cluster_name}-${replace(each.key,"_","-")}-mysql-readonly-secret"
  value        = random_string.mysql_reader_password[each.key].result
  key_vault_id = var.key_vault_id
}
