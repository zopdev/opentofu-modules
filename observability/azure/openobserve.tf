# Create Azure Storage Container for OpenObserve data storage (auto-generated container names)
resource "azurerm_storage_container" "openobserve_data" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}

  name                  = "${local.cluster_name}-openobserve-${each.value.name}-${var.observability_suffix}"
  storage_account_name  = var.storage_account
  container_access_type = "private"
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
  openobserve_templates = local.enable_openobserve ? {
    for instance in var.openobserve :
    instance.name => templatefile(
      "${path.module}/templates/openobserve-values.yaml",
      {
        replica_count       = try(instance.replicaCount, 2)
        cpu_request         = try(instance.min_cpu, "250m")
        memory_request      = try(instance.min_memory, "1Gi")
        cpu_limit           = try(instance.max_cpu, "1")
        memory_limit        = try(instance.max_memory, "2Gi")
        storage_provider    = "azure"
        storage_region      = "auto"
        storage_bucket_name = azurerm_storage_container.openobserve_data[instance.name].name
        root_user_email     = "admin@zop.dev"
        root_user_password  = random_password.openobserve_password[instance.name].result
        storage_account     = var.storage_account
        account_key         = var.account_access_key

        additional_env_vars = length(try(instance.env, [])) > 0 ? join("\n",
          [ for env in instance.env :
              "  - name: ${env.name}\n    value: \"${env.value}\""
            ]
          ) : ""
      }
    )
    if instance.enable
  } : {}
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
    local.openobserve_templates[each.key]
  ]

  depends_on = [
    azurerm_storage_container.openobserve_data,
    kubernetes_namespace.app_environments,
  ]
}
