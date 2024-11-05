output "db_admin_user" {
  value = azurerm_postgresql_flexible_server.postgres_server.administrator_login
}

output "db_password" {
  value     = azurerm_postgresql_flexible_server.postgres_server.administrator_password
  sensitive = true
}

output "db_port" {
  value = "5432"
}

output "db_url" {
  value = azurerm_postgresql_flexible_server.postgres_server.fqdn
}

output "db_name" {
  value = azurerm_postgresql_flexible_server.postgres_server.name
}

output "server_name" {
  value = azurerm_postgresql_flexible_server.postgres_server.name
}

output "server_id" {
  value = azurerm_postgresql_flexible_server.postgres_server.id
}

output "db_version" {
  value = azurerm_postgresql_flexible_server.postgres_server.version
}

output "storage" {
  value = azurerm_postgresql_flexible_server.postgres_server.storage_mb
}

output "sku_name" {
  value = azurerm_postgresql_flexible_server.postgres_server.sku_name
}

output "db_user" {
  value = {
    for k,v in local.db_map : k => v.user
  }
}