data "azurerm_subscription" "current" {}

locals {
  cluster_name = var.app_env == "" ? var.app_name : "${var.app_name}-${var.app_env}"
  cluster_name_parts = split("-", local.cluster_name)
  environment = var.app_env == "" ? element(local.cluster_name_parts, length(local.cluster_name_parts) - 1) : var.app_env
  common_tags = merge(var.common_tags,
    tomap({
      Project     = local.cluster_name,
      Provisioner = "TERRAFORM",
      Environment = local.environment,
    }))
}

resource "kubernetes_namespace" "app_environments" {

  metadata {
    name = var.namespace
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "azuread_application" "namespace_sp" {
  display_name = "${local.cluster_name}-${var.namespace}"
}

resource "azuread_service_principal" "namespace_sp" {
  application_id = azuread_application.namespace_sp.application_id
}

resource "azuread_service_principal_password" "namespace_sp_pwd" {
  service_principal_id = azuread_service_principal.namespace_sp.id
}

resource "azurerm_role_assignment" "namespace_acr_access" {
  for_each             = local.services_acr_name_map
  scope                = data.azurerm_container_registry.acr[each.key].id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.namespace_sp.id
}

resource "azurerm_role_assignment" "namespace_editor" {
  scope                = "${data.azurerm_kubernetes_cluster.cluster.id}/namespace/${var.namespace}"
  role_definition_name = "Azure Kubernetes Service RBAC Writer"
  principal_id         = azuread_service_principal.namespace_sp.id
}