# Create GCS bucket for OpenObserve data storage (auto-generated bucket names)
resource "google_storage_bucket" "openobserve_data" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}
  
  name          = "${local.cluster_name}-openobserve-${each.value.name}-${var.observability_suffix}"
  location      = var.app_region
  project       = var.project_id
  force_destroy = true
  labels        = var.labels
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

# Create template for OpenObserve values
data "template_file" "openobserve_template" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}
  
  template = file("${path.module}/templates/openobserve-values.yaml")
  vars = {
    replica_count        = try(each.value.replicaCount, 1)
    cpu_request          = try(each.value.min_cpu, "250m")
    memory_request       = try(each.value.min_memory, "512Mi")
    cpu_limit           = try(each.value.max_cpu, "1")
    memory_limit        = try(each.value.max_memory, "1Gi")
    storage_provider    = "gcs"
    storage_region      = "auto"
    storage_bucket_name = google_storage_bucket.openobserve_data[each.key].name
    storage_access_key_path = "/app/key.json"
    secret_name         = "openobserve-gcs-creds-${each.value.name}"
    additional_env_vars = length(try(each.value.env, [])) > 0 ? join("\n", [for env in each.value.env : "  - name: ${env.name}\n    value: \"${env.value}\""]) : ""
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
    data.template_file.openobserve_template[each.key].rendered
  ]

  depends_on = [
    kubernetes_secret.openobserve-gcs-credentials,
  ]
}