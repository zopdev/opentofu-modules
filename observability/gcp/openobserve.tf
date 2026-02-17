# Create GCS bucket for OpenObserve data storage (auto-generated bucket names)
resource "google_storage_bucket" "openobserve_data" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}
  
  name          = "${local.cluster_name}-openobserve-${each.value.name}-${var.observability_suffix}"
  location      = var.app_region
  project       = var.project_id
  force_destroy = false
  labels        = var.labels

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  lifecycle {
    prevent_destroy = true
  }
}

# Create service account for OpenObserve
resource "google_service_account" "openobserve_svc_acc" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}
  
  project    = var.project_id
  account_id = substr("${var.service_account_name_prefix}-oo-${each.value.name}", 0, 30)
}

# Create service account key
resource "google_service_account_key" "openobserve_svc_acc_key" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}
  
  service_account_id = google_service_account.openobserve_svc_acc[each.key].name
}

# Grant storage permissions to service account
resource "google_storage_bucket_iam_member" "openobserve_svc_acc_storage" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}
  
  bucket      = google_storage_bucket.openobserve_data[each.key].name
  role        = "roles/storage.objectAdmin"
  member      = "serviceAccount:${google_service_account.openobserve_svc_acc[each.key].email}"
}

# Grant IAM permissions to service account
resource "google_project_iam_member" "openobserve_svc_acc_iam" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}
  
  project     = var.project_id
  role        = "roles/iam.serviceAccountTokenCreator"
  member      = "serviceAccount:${google_service_account.openobserve_svc_acc[each.key].email}"
}

# Create Kubernetes secret for GCS credentials (auto-generated secret names)
resource "kubernetes_secret" "openobserve-gcs-credentials" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}
  
  metadata {
    name      = "openobserve-gcs-creds-${each.value.name}"
    namespace = kubernetes_namespace.app_environments["openobserve"].metadata[0].name
    labels    = { app = var.app_name }
    annotations = {
      "kubernetes.io/service-account.name" = "${local.cluster_name}-openobserve-${each.key}-google-credentials"
    }
  }

  data = {
    "key.json" = base64decode(google_service_account_key.openobserve_svc_acc_key[each.key].private_key)
  }

  type = "Opaque"
}

# Generate random password for OpenObserve
resource "random_password" "openobserve_password" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}
  
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# Create template for OpenObserve values
locals {
  openobserve_template = {
    for inst in var.openobserve : inst.name => inst.enable ? templatefile("${path.module}/templates/openobserve-values.yaml", {
      replica_count         = try(inst.replicaCount, 1)
      cpu_request           = "250m"
      memory_request        = "1Gi"
      cpu_limit             = "1"
      memory_limit          = "2Gi"
      storage_provider      = "gcs"
      storage_region        = "auto"
      storage_bucket_name   = google_storage_bucket.openobserve_data[inst.name].name
      storage_access_key_path = "/app/key.json"
      secret_name           = "openobserve-gcs-creds-${inst.name}"
      root_user_email       = "admin@zop.dev"
      root_user_password    = random_password.openobserve_password[inst.name].result
      additional_env_vars   = length(try(inst.env, [])) > 0 ? join("\n", [for env in inst.env : "  - name: ${env.name}\n    value: \"${env.value}\""]) : ""
    }) : null
  }
}


# Deploy OpenObserve using Helm
resource "helm_release" "openobserve" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}
  
  name       = each.value.name
  repository = "https://helm.zop.dev"
  chart      = "openobserve-standalone"
  version    = "v1.0.0"
  namespace  = kubernetes_namespace.app_environments["openobserve"].metadata[0].name

  values = [
    local.openobserve_template[each.key]
  ]

  depends_on = [
    kubernetes_secret.openobserve-gcs-credentials,
  ]
}