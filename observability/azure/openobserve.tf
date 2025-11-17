# Create Azure Storage Container for OpenObserve data storage (auto-generated container names)
resource "azurerm_storage_container" "openobserve_data" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}
  
  name                  = "${local.cluster_name}-openobserve-${each.value.name}-${var.observability_suffix}"
  storage_account_name  = var.storage_account
  container_access_type = "private"
}

# Create Kubernetes secret for Azure credentials (auto-generated secret names)
resource "kubernetes_secret" "openobserve-azure-credentials" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}
  
  metadata {
    name      = "openobserve-azure-creds-${each.value.name}"
    namespace = kubernetes_namespace.app_environments["openobserve"].metadata[0].name
    labels    = { app = var.app_name }
    annotations = {
      "kubernetes.io/service-account.name" = "${local.cluster_name}-openobserve-${each.key}-azure-credentials"
    }
  }

  data = {
    "AZURE_STORAGE_ACCOUNT_NAME" = base64encode(var.storage_account)
    "AZURE_STORAGE_ACCOUNT_KEY"  = base64encode(var.account_access_key)
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
data "template_file" "openobserve_template" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}
  
  template = file("${path.module}/templates/openobserve-values.yaml")
  vars = {
    replica_count        = try(each.value.replicaCount, 2)
    cpu_request          = try(each.value.min_cpu, "500m")
    memory_request       = try(each.value.min_memory, "512Mi")
    cpu_limit           = try(each.value.max_cpu, "1")
    memory_limit        = try(each.value.max_memory, "1Gi")
    storage_provider    = "azure"
    storage_region      = "auto"
    storage_bucket_name = azurerm_storage_container.openobserve_data[each.key].name
    storage_access_key_path = "/app/key.json"
    secret_name         = "openobserve-azure-creds-${each.value.name}"
    root_user_email     = "admin@zop.dev"
    root_user_password  = random_password.openobserve_password[each.key].result
    storage_account     = var.storage_account
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
    kubernetes_secret.openobserve-azure-credentials,
  ]
}
