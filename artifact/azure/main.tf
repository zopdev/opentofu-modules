resource "azurerm_container_registry" "acr_repo" {
  for_each             = toset(var.services)
  name                 = each.value
  resource_group_name  = var.resource_group_name
  location             = var.app_region
  sku                  = var.sku  # You can choose the appropriate SKU for your needs

  identity {
    type = "SystemAssigned"
  }
}