output "vnet" {
  description = "Map of VNet names to their IDs"
  value = {
    for k, v in azurerm_virtual_network.vnet : k => v.id
  }
}

output "private_subnets" {
  description = "List of private subnet names"
  value       = [for subnet in azurerm_subnet.private : subnet.name]
}

output "database_subnets" {
  description = "List of database subnet names"
  value       = [for subnet in azurerm_subnet.database : subnet.name]
}

output "private_subnet_ids" {
  description = "Map of private subnet names to their IDs"
  value = {
    for k, v in azurerm_subnet.private : v.name => v.id
  }
}

output "database_subnet_ids" {
  description = "Map of database subnet names to their IDs"
  value = {
    for k, v in azurerm_subnet.database : v.name => v.id
  }
}