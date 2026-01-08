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
  description = "List of database subnet names (includes both PostgreSQL and MySQL subnets)"
  value = concat(
    [for subnet in azurerm_subnet.postgresql : subnet.name],
    [for subnet in azurerm_subnet.mysql : subnet.name]
  )
}

output "postgresql_subnets" {
  description = "List of PostgreSQL subnet names"
  value       = [for subnet in azurerm_subnet.postgresql : subnet.name]
}

output "mysql_subnets" {
  description = "List of MySQL subnet names"
  value       = [for subnet in azurerm_subnet.mysql : subnet.name]
}

output "private_subnet_ids" {
  description = "Map of private subnet names to their IDs"
  value = {
    for k, v in azurerm_subnet.private : v.name => v.id
  }
}

output "database_subnet_ids" {
  description = "Map of database subnet names to their IDs (includes both PostgreSQL and MySQL)"
  value = merge(
    { for k, v in azurerm_subnet.postgresql : v.name => v.id },
    { for k, v in azurerm_subnet.mysql : v.name => v.id }
  )
}

output "postgresql_subnet_ids" {
  description = "Map of PostgreSQL subnet names to their IDs"
  value = {
    for k, v in azurerm_subnet.postgresql : v.name => v.id
  }
}

output "mysql_subnet_ids" {
  description = "Map of MySQL subnet names to their IDs"
  value = {
    for k, v in azurerm_subnet.mysql : v.name => v.id
  }
}