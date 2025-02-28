locals {
  db_map = tomap({
  for database in var.databases : "${var.namespace}-${database}" => {
      master_db = var.namespace
      db_name   = database
      user      = "${database}_${random_string.db_username[database].result}"
    } if database != null
  })
}

resource "random_password" "rds_password" {
  length   = 16
  special  = false
}

resource "random_string" "editor_password" {
  length   = 16
  special  = false
  for_each = local.db_map
}

resource "random_string" "reader_password" {
  length   = 16
  special  = false
  for_each = local.db_map
}

resource "random_string" "db_username" {
  length   = 6
  special  = false
  for_each = {for v in var.databases : v => v if v != null}
}

resource "aws_secretsmanager_secret" "db_secret" {
  name     = var.multi_ds ? "${var.cluster_name}-${var.namespace}-${var.rds_name}-db-secret" : "${var.cluster_name}-${var.namespace}-db-secret"
  tags     = var.tags
}

resource "aws_secretsmanager_secret_version" "db_secret" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = random_password.rds_password.result
}

resource "aws_secretsmanager_secret" "db_user_secret" {
  for_each = local.db_map
  name     = "${var.cluster_name}-${each.key}-db-user-secret"
  tags     = var.tags
}

resource "aws_secretsmanager_secret_version" "db_user_secret" {
  for_each      = local.db_map
  secret_id     = aws_secretsmanager_secret.db_user_secret[each.key].id
  secret_string = each.value.user
}

resource "aws_secretsmanager_secret" "db_editor_secret" {
  for_each = local.db_map
  name     = "${var.cluster_name}-${each.key}-db-secret"
  tags     = var.tags
}

resource "aws_secretsmanager_secret_version" "db_editor_secret" {
  for_each      = local.db_map
  secret_id     = aws_secretsmanager_secret.db_editor_secret[each.key].id
  secret_string = random_string.editor_password[each.key].result
}


resource "aws_secretsmanager_secret" "readonly_db_secret" {
  for_each = local.db_map
  name     = "${var.cluster_name}-${each.key}-readonly-secret"
  tags     = var.tags
}

resource "aws_secretsmanager_secret_version" "readonly_db_secret" {
  for_each      = local.db_map
  secret_id     = aws_secretsmanager_secret.readonly_db_secret[each.key].id
  secret_string = random_string.reader_password[each.key].result
}