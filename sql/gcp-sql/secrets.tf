locals {
  db_map = tomap({
    for database in var.databases : "${var.namespace}-${database}" => {
      master_db = var.namespace
      db_name   = database
      user = "${database}_${random_string.db_username[database].result}"
    } if database != null
  })
}

resource "random_password" "sql_password" {
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
  length  = 6
  special = false
  for_each = {for v in var.databases : v => v if v != null}
}

resource "google_secret_manager_secret" "db_secret" {

  provider          = google-beta
  project           = var.project_id
  secret_id = var.multi_ds ? "${var.cluster_name}-${var.namespace}-${replace(var.sql_name, "_", "-")}-db-secret" : "${var.cluster_name}-${var.namespace}-db-secret"  labels            = var.labels

  replication {
    automatic   = true
  }
}

resource "google_secret_manager_secret_iam_member" "db_secret_binding" {
  project       = var.project_id
  secret_id     = google_secret_manager_secret.db_secret.secret_id
  role          = "roles/secretmanager.secretAccessor"
  member        = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret_version" "db_secret" {
  secret          = google_secret_manager_secret.db_secret.id
  secret_data     = random_password.sql_password.result
  depends_on      = [google_secret_manager_secret.db_secret]
}

resource "google_secret_manager_secret" "db_user_secret" {
  for_each  = local.db_map
  provider  = google-beta
  project   = var.project_id
  secret_id = "${var.cluster_name}-${each.key}-db-user-secret"

  replication {
    automatic   = true
  }
}

resource "google_secret_manager_secret_version" "db_user_secret" {
  for_each  = local.db_map
  secret      = google_secret_manager_secret.db_user_secret[each.key].id
  secret_data = each.value.user
}

resource "google_secret_manager_secret_iam_member" "db_user_secret_binding" {
  for_each  = local.db_map
  project       = var.project_id
  secret_id     = google_secret_manager_secret.db_user_secret[each.key].id
  role          = "roles/secretmanager.secretAccessor"
  member        = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret" "db_editor_secret" {
  for_each  = local.db_map

  provider         = google-beta
  project          = var.project_id
  secret_id        = "${var.cluster_name}-${each.key}-db-secret"
  labels           = var.labels

  replication {
    automatic   = true
  }
}

resource "google_secret_manager_secret_iam_member" "db_editor_secret_binding" {
  for_each  =  local.db_map

  project     = var.project_id
  secret_id   = google_secret_manager_secret.db_editor_secret[each.key].secret_id
  role        = "roles/secretmanager.secretAccessor"
  member      = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret_version" "db_editor_secret" {
  for_each  = local.db_map
  secret          = google_secret_manager_secret.db_editor_secret[each.key].id
  secret_data     = random_string.editor_password[each.key].result
  depends_on      = [google_secret_manager_secret.db_editor_secret]
}

resource "google_secret_manager_secret" "readonly_db_secret" {
  for_each          = local.db_map

  provider          = google-beta
  project           = var.project_id
  secret_id         = "${var.cluster_name}-${each.key}-readonly-secret"
  labels            = var.labels

  replication {
    automatic   = true
  }
}

resource "google_secret_manager_secret_iam_member" "readonly_db_secret_binding" {
  for_each         = local.db_map

  project          = var.project_id
  secret_id        = google_secret_manager_secret.readonly_db_secret[each.key].secret_id
  role             = "roles/secretmanager.secretAccessor"
  member           = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret_version" "readonly_db_secret" {
  for_each      = local.db_map
  secret        = google_secret_manager_secret.readonly_db_secret[each.key].id
  secret_data   = random_string.reader_password[each.key].result
  depends_on    = [google_secret_manager_secret.readonly_db_secret]
}

resource "google_secret_manager_secret" "client_cert" {
  count             = var.enable_ssl ? 1 : 0
  provider          = google-beta
  project           = var.project_id
  secret_id         = "${var.cluster_name}-${var.namespace}-client-certificate"

  replication {
    automatic   = true
  }
}

resource "google_secret_manager_secret_iam_member" "client_cert_binding" {
  count         = var.enable_ssl ? 1 : 0
  project       = var.project_id
  secret_id     = google_secret_manager_secret.client_cert[count.index].secret_id
  role          = "roles/secretmanager.secretAccessor"
  member        = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret_version" "client_cert" {
  count           = var.enable_ssl ? 1 : 0
  secret          = google_secret_manager_secret.client_cert[count.index].id
  secret_data     = var.sql_type == "postgresql" ? google_sql_ssl_cert.postgresql_db_cert[count.index].cert : google_sql_ssl_cert.sql_db_cert[count.index].cert
  depends_on      = [google_secret_manager_secret.client_cert]
}

resource "google_secret_manager_secret" "client_key" {
  count             = var.enable_ssl ? 1 : 0
  provider          = google-beta
  project           = var.project_id
  secret_id         = "${var.cluster_name}-${var.namespace}-client-key"

  replication {
    automatic   = true
  }
}

resource "google_secret_manager_secret_iam_member" "client_key_binding" {
  count         = var.enable_ssl ? 1 : 0
  project       = var.project_id
  secret_id     = google_secret_manager_secret.client_key[count.index].secret_id
  role          = "roles/secretmanager.secretAccessor"
  member        = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret_version" "client_key" {
  count           = var.enable_ssl ? 1 : 0
  secret          = google_secret_manager_secret.client_key[count.index].id
  secret_data     = var.sql_type == "postgresql" ? google_sql_ssl_cert.postgresql_db_cert[count.index].private_key : google_sql_ssl_cert.sql_db_cert[count.index].private_key
  depends_on      = [google_secret_manager_secret.client_key]
}

resource "google_secret_manager_secret" "server_cert" {
  count             = var.enable_ssl ? 1 : 0
  provider          = google-beta
  project           = var.project_id
  secret_id         = "${var.cluster_name}-${var.namespace}-server-certificate"

  replication {
    automatic   = true
  }
}

resource "google_secret_manager_secret_iam_member" "server_cert_binding" {
  count         = var.enable_ssl ? 1 : 0
  project       = var.project_id
  secret_id     = google_secret_manager_secret.server_cert[count.index].secret_id
  role          = "roles/secretmanager.secretAccessor"
  member        = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret_version" "server_cert" {
  count           = var.enable_ssl ? 1 : 0
  secret          = google_secret_manager_secret.server_cert[count.index].id
  secret_data     = var.sql_type == "postgresql" ? google_sql_ssl_cert.postgresql_db_cert[count.index].server_ca_cert : google_sql_ssl_cert.sql_db_cert[count.index].server_ca_cert
  depends_on      = [google_secret_manager_secret.server_cert]
}