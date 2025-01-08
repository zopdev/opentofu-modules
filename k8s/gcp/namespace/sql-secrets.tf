locals {
  project_number = data.google_project.this.number
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

resource "google_secret_manager_secret" "db_user_secret" {
  for_each  = local.db_map
  provider  = google-beta
  project   = var.provider_id
  secret_id = "${local.cluster_name}-${each.key}-db-user-secret"

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
  project       = var.provider_id
  secret_id     = google_secret_manager_secret.db_user_secret[each.key].id
  role          = "roles/secretmanager.secretAccessor"
  member        = "serviceAccount:${local.project_number}-compute@developer.gserviceaccount.com"
}


resource "google_secret_manager_secret" "db_editor_secret" {
  for_each  = local.db_map

  provider         = google-beta
  project          = var.provider_id
  secret_id        = "${local.cluster_name}-${each.key}-db-secret"
  labels           = local.common_tags

  replication {
    automatic   = true
  }
}

resource "google_secret_manager_secret_iam_member" "db_editor_secret_binding" {
  for_each  =  local.db_map

  project     = var.provider_id
  secret_id   = google_secret_manager_secret.db_editor_secret[each.key].secret_id
  role        = "roles/secretmanager.secretAccessor"
  member      = "serviceAccount:${local.project_number}-compute@developer.gserviceaccount.com"
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
  project           = var.provider_id
  secret_id         = "${local.cluster_name}-${each.key}-readonly-secret"
  labels            = local.common_tags

  replication {
    automatic   = true
  }
}

resource "google_secret_manager_secret_iam_member" "readonly_db_secret_binding" {
  for_each         = local.db_map

  project          = var.provider_id
  secret_id        = google_secret_manager_secret.readonly_db_secret[each.key].secret_id
  role             = "roles/secretmanager.secretAccessor"
  member           = "serviceAccount:${local.project_number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret_version" "readonly_db_secret" {
  for_each      = local.db_map
  secret        = google_secret_manager_secret.readonly_db_secret[each.key].id
  secret_data   = random_string.reader_password[each.key].result
  depends_on    = [google_secret_manager_secret.readonly_db_secret]
}