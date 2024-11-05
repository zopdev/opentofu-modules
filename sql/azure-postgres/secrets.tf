locals {
  db_map = tomap({
    for database in var.databases : "${var.namespace}-${database}" => {
      master_db = var.namespace
      db_name   = database
      user = "${database}_${random_string.postgres_username[database].result}"
    } if database != null
  })
}

resource "random_password" "postgresql_db_password" {
  length   = 16
  special  = true
}

resource "random_string" "postgres_username" {
  length   = 6
  special  = false
  for_each = {for v in var.databases : v => v if v != null}
}

resource "random_string" "postgres_editor_password" {
  length   = 16
  special  = false
  for_each = local.db_map
}

resource "random_string" "postgres_reader_password" {
  length   = 16
  special  = false
  for_each = local.db_map
}

resource "azurerm_key_vault_secret" "postgres_db_secret" {
  name         = "${var.cluster_name}-${var.namespace}-postgres-db-secret"
  value        = random_password.postgresql_db_password.result
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "postgres_db_user_secret" {
  for_each     = local.db_map
  name         = "${var.cluster_name}-${replace(each.key,"_","-")}-mysql-db-user-secret"
  value        = each.value.user
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "postgres_db_editor_secret" {
  for_each     = local.db_map
  name         = "${var.cluster_name}-${replace(each.key,"_","-")}-postgres-db-secret"
  value        = random_string.postgres_editor_password[each.key].result
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "postgres_db_readonly_secret" {
  for_each     = local.db_map
  name         = "${var.cluster_name}-${replace(each.key,"_","-")}-postgres-readonly-secret"
  value        = random_string.postgres_reader_password[each.key].result
  key_vault_id = var.key_vault_id
}
