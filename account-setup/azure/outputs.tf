output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = try(azurerm_virtual_network.vnet[0].id, null)
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = try(azurerm_virtual_network.vnet[0].name, null)
}

output "vnet_address_space" {
  description = "The address space of the Virtual Network"
  value       = try(azurerm_virtual_network.vnet[0].address_space, [])
}

output "private_subnet_id" {
  description = "The ID of the private subnet (for AKS nodes and services)"
  value       = try(azurerm_subnet.private[0].id, null)
}

output "private_subnet_name" {
  description = "The name of the private subnet"
  value       = try(azurerm_subnet.private[0].name, null)
}

output "database_subnet_id" {
  description = "The ID of the database subnet"
  value       = try(azurerm_subnet.database[0].id, null)
}

output "database_subnet_name" {
  description = "The name of the database subnet"
  value       = try(azurerm_subnet.database[0].name, null)
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = try(azurerm_nat_gateway.nat_gateway[0].id, null)
}