data "azurerm_subscription" "current" {}

resource "random_password" "aks_sp_pwd" {
  length  = 16
  special = false
}

locals {
  cluster_name = var.app_env == "" ? var.app_name : "${var.app_name}-${var.app_env}"
  cluster_name_parts = split("-", local.cluster_name)
  environment        = var.app_env == "" ? element(local.cluster_name_parts, length(local.cluster_name_parts) - 1) : var.app_env
  node_port    = 32443 # Node port which will be used by LB for exposure

  common_tags        = merge(var.common_tags,
    tomap({
      Project     = local.cluster_name,
      Provisioner = "zop-dev",
    }))
}

#resource "azuread_application" "aks_sp" {
#  display_name               = local.cluster_name
#}
#
#resource "azuread_service_principal" "aks_sp" {
#  application_id = azuread_application.aks_sp.application_id
#}
#
#resource "azuread_service_principal_password" "aks_sp_pwd" {
#  service_principal_id = azuread_service_principal.aks_sp.id
#}
#
#resource "azurerm_role_assignment" "aks_sp_role_assignment" {
#  scope                = data.azurerm_subscription.current.id
#  role_definition_name = "Contributor"
#  principal_id         = azuread_service_principal.aks_sp.id
#
#  depends_on = [
#    azuread_service_principal_password.aks_sp_pwd
#  ]
#}

module "aks" {
  source = "Azure/aks/azurerm"

  prefix                             = local.cluster_name
  resource_group_name                = var.resource_group_name
  location                           = var.app_region
  admin_username                     = null
  azure_policy_enabled               = true
  log_analytics_workspace_enabled    = var.log_analytics_workspace_enabled
  private_cluster_enabled            = false
  rbac_aad_managed                   = true
  role_based_access_control_enabled  = true
  rbac_aad_admin_group_object_ids    = [azuread_group.aks_aad_cluster_admins.id]
  rbac_aad_tenant_id                 = data.azurerm_subscription.current.tenant_id
  identity_type                      = "SystemAssigned"
  enable_auto_scaling                = var.enable_auto_scaling
  agents_pool_name                   = var.app_name
  agents_size                        = var.node_config.node_type
  agents_max_count                   = var.node_config.max_count
  agents_min_count                   = var.node_config.min_count
  key_vault_secrets_provider_enabled = true
  kubernetes_version                 = 1.28
  workload_identity_enabled          = true
  oidc_issuer_enabled                = true
  temporary_name_for_rotation        = "${var.app_name}1"

  tags = merge(local.common_tags,
    tomap({
      "Name" = local.cluster_name
    })
  )
}

resource "null_resource" "aks_vmss_managed_identity" {
  triggers = {
    node_config = var.node_config.node_type
  }
  provisioner "local-exec" {
    command = "az vmss identity assign -g ${module.aks.node_resource_group} -n ${data.azurerm_resources.aks_vmscaleset_resource.resources[0].name}"
  }
  depends_on = [module.aks]
}