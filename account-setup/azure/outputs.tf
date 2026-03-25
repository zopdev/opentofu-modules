output "vnet" {
  value     = try(azurerm_virtual_network.vnet[0].address_space,0)
}