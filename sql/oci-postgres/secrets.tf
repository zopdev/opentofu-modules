locals {
  db_map = tomap({
    for database in var.databases : "${var.namespace}-${database}" => {
      master_db = var.namespace
      db_name   = database
      user      = "${database}_${random_string.postgres_username[database].result}"
    } if database != null
  })
}

resource "random_password" "db_admin_password" {
  length           = 16
  special          = true
  override_special = "!@$_+-=?"
  upper            = true
  lower            = true
  numeric          = true
}

resource "random_string" "postgres_username" {
  length   = 6
  special  = false
  for_each = { for v in var.databases : v => v if v != null }
}

resource "random_password" "postgres_editor_password" {
  length      = 16
  special     = true
  upper       = true
  lower       = true
  numeric     = true
  min_special = 2
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  for_each    = local.db_map
}

resource "random_password" "postgres_reader_password" {
  length      = 16
  special     = true
  upper       = true
  lower       = true
  numeric     = true
  min_special = 2
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  for_each    = local.db_map
}

resource "oci_vault_secret" "admin_password_secret" {
  compartment_id = var.provider_id
  secret_name    = "${var.postgres_db_system_name}-postgres-db-secret"
  secret_content {
    content_type = "base64"
    content      = base64encode(random_password.db_admin_password.result)
  }
  key_id   = var.key_id
  vault_id = var.vault_id
}

resource "oci_vault_secret" "postgres_db_user_secret" {
  for_each       = local.db_map
  compartment_id = var.provider_id
  secret_name    = "${var.postgres_db_system_name}-${replace(each.key, "_", "-")}-postgres-user"
  vault_id       = var.vault_id
  key_id         = var.key_id

  secret_content {
    content_type = "BASE64"
    content      = base64encode(each.value.user)
  }
}

resource "oci_vault_secret" "postgres_db_editor_secret" {
  for_each       = local.db_map
  compartment_id = var.provider_id
  secret_name    = "${var.postgres_db_system_name}-${replace(each.key, "_", "-")}-postgres-db"
  vault_id       = var.vault_id
  key_id         = var.key_id

  secret_content {
    content_type = "BASE64"
    content      = base64encode(random_password.postgres_editor_password[each.key].result)
  }
}

resource "oci_vault_secret" "postgres_db_readonly_secret" {
  for_each       = local.db_map
  compartment_id = var.provider_id
  secret_name    = "${var.postgres_db_system_name}-${replace(each.key, "_", "-")}-postgres-readonly"
  vault_id       = var.vault_id
  key_id         = var.key_id

  secret_content {
    content_type = "BASE64"
    content      = base64encode(random_password.postgres_reader_password[each.key].result)
  }
}

data "oci_secrets_secretbundle" "admin_password_bundle" {
  secret_id = oci_vault_secret.admin_password_secret.id
}

data "oci_secrets_secretbundle" "postgres_db_editor_secret" {
  for_each  = local.db_map
  secret_id = oci_vault_secret.postgres_db_editor_secret[each.key].id
}

data "oci_secrets_secretbundle" "postgres_db_readonly_secret" {
  for_each  = local.db_map
  secret_id = oci_vault_secret.postgres_db_readonly_secret[each.key].id
}
