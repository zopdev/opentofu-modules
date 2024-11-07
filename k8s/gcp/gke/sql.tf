resource "kubernetes_namespace" "db_namespace" {
  metadata {
    name = "db"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "google_service_account" "sql_proxy" {
  account_id   = "${local.cluster_service_account_name}-sqlproxy"
  description  = "Service account for PostgreSQL sqlproxy."
  project      = var.provider_id
}

resource "google_service_account_key" "sql_proxy" {
  service_account_id = google_service_account.sql_proxy.name
}

resource "google_project_iam_member" "sql_proxy" {
  project     = var.provider_id
  role        = "roles/cloudsql.client"

  member     = "serviceAccount:${google_service_account.sql_proxy.email}"
}


resource "google_project_iam_member" "networking" {
  project     = var.provider_id
  role        = "roles/compute.networkAdmin"

  member     = "serviceAccount:${google_service_account.sql_proxy.email}"
}

resource "kubernetes_secret" "sql_proxy" {
  metadata {
    name      = "sqlproxy-config-svc-acc"
    namespace = "db"
  }

  data = {
    GCP_SERVICE_ACCOUNT_KEY = base64decode(google_service_account_key.sql_proxy.private_key)
  }
  depends_on = [kubernetes_namespace.db_namespace]
}