locals {
  mimir_template = local.enable_mimir ? templatefile("${path.module}/templates/mimir-values.yaml", {
    data_bucket_name                 = google_storage_bucket.mimir_data[0].id
    cluster_name                     = local.cluster_name
    limits_ingestion_rate            = try(var.mimir.limits.ingestion_rate, "500000")
    limits_ingestion_burst_size      = try(var.mimir.limits.ingestion_burst_size, "1000000")
    limits_max_fetched_chunks_per_query = try(var.mimir.limits.max_fetched_chunks_per_query, "5000000")
    limits_max_cache_freshness       = try(var.mimir.limits.max_cache_freshness, "12h")
    limits_max_outstanding_requests_per_tenant = try(var.mimir.limits.max_outstanding_requests_per_tenant, "2000")
    compactor_replicas               = try(var.mimir.compactor.replicas, "2")
    compactor_persistence_volume_enable = try(var.mimir.compactor.persistence_volume.enable, "true")
    compactor_persistence_volume_size = try(var.mimir.compactor.persistence_volume.size, "50Gi")
    # ... all other variables in same style
    mimir_basic_auth_username        = random_password.mimir_basic_auth_username[0].result
    mimir_basic_auth_password        = random_password.mimir_basic_auth_password[0].result
  }) : null
}

resource "google_storage_bucket" "mimir_data" {
  count = local.enable_mimir ? 1 : 0
  name          = "${local.cluster_name}-mimir-block-data-${var.observability_suffix}"
  location      = var.app_region
  project       = var.project_id
  force_destroy = true
  labels        = var.labels
}

resource "google_service_account" "mimir_svc_acc" {
  count = local.enable_mimir ? 1 : 0
  project    = var.project_id
  account_id = "${var.service_account_name_prefix}-mimir-data"
}

resource "google_service_account_key" "mimir_svc_acc_key" {
  count = local.enable_mimir ? 1 : 0
  service_account_id = google_service_account.mimir_svc_acc[0].name
}

resource "google_storage_bucket_iam_member" "mimir_svc_acc" {
  count = local.enable_mimir ? 1 : 0
  bucket      = google_storage_bucket.mimir_data[0].name
  role        = "roles/storage.objectAdmin"
  member      = "serviceAccount:${google_service_account.mimir_svc_acc[0].email}"
}

resource "random_password" "mimir_basic_auth_username" {
  count   = local.enable_mimir ? 1 : 0
  length  = 16
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "random_password" "mimir_basic_auth_password" {
  count   = local.enable_mimir ? 1 : 0
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "kubernetes_secret" "mimir-basic-auth" {
  count = local.enable_mimir ? 1 : 0
  metadata {
    name      = "mimir-basic-auth"
    namespace = kubernetes_namespace.app_environments["mimir"].metadata[0].name
    labels    = { app = var.app_name }
  }

  data = {
    # NGINX Ingress Controller expects the key to be 'auth' for basic auth
    auth = "${random_password.mimir_basic_auth_username[0].result}:${bcrypt(random_password.mimir_basic_auth_password[0].result)}"
  }

  type = "Opaque"
}

resource "kubernetes_secret" "mimir-google-credentials" {
  count = local.enable_mimir ? 1 : 0
  metadata {
    name      = "${local.cluster_name}-mimir-google-credentials"
    namespace = kubernetes_namespace.app_environments["mimir"].metadata[0].name
    labels    = { app = var.app_name }
    annotations = {
      "kubernetes.io/service-account.name" = "${local.cluster_name}-mimir-google-credentials"
    }
  }

  data = {
    "gcs.json" = base64decode(google_service_account_key.mimir_svc_acc_key[0].private_key)
  }

  type = "Opaque"
}

resource "helm_release" "mimir" {
  count = local.enable_mimir ? 1 : 0
  name       = "mimir"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "mimir-distributed"
  namespace  = kubernetes_namespace.app_environments["mimir"].metadata[0].name
  version    = "5.1.3"
  values = [
    local.mimir_template
  ]

  depends_on = [
    kubernetes_secret.mimir-google-credentials,
    kubernetes_secret.mimir-basic-auth,
  ]
}
