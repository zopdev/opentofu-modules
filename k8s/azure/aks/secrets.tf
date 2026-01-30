data "azurerm_client_config" "current" {}

data "azurerm_resources" "aks_vmscaleset_resource" {
  resource_group_name = module.aks.node_resource_group
  type                = "Microsoft.Compute/virtualMachineScaleSets"
}

data "azurerm_virtual_machine_scale_set" "aks_vmscaleset_resource" {
  name                = data.azurerm_resources.aks_vmscaleset_resource.resources[0].name
  resource_group_name = module.aks.node_resource_group
  depends_on = [null_resource.aks_vmss_managed_identity]
}

resource "random_string" "key_vault_name" {
  length = 6
  special = false
  numeric = false
}

resource "azurerm_key_vault" "secrets" {
  name                       = "${local.cluster_name}-${random_string.key_vault_name.result}"
  location                   = var.app_region
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "GetRotationPolicy",
      "List",
      "SetRotationPolicy",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "List",
      "Purge",
      "Recover",
    ]

    certificate_permissions = [
    "Get",
    ]
  }

  access_policy {
    object_id = data.azurerm_virtual_machine_scale_set.aks_vmscaleset_resource.identity[0].principal_id
    tenant_id = data.azurerm_client_config.current.tenant_id



    key_permissions = [
      "Get",
      "List"
    ]

    secret_permissions = [
      "Get",
      "List"
    ]

    certificate_permissions = [
      "Get",
      "List"
    ]

  }
  depends_on = [module.aks, null_resource.aks_vmss_managed_identity]
}