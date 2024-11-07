output "db_admin_user" {
  value = azurerm_mysql_flexible_server.mysql_server.administrator_login
}

output "db_password" {
  value     = azurerm_mysql_flexible_server.mysql_server.administrator_password
  sensitive = true
}

output "db_port" {
  value = "3306"
}

output "db_url" {
  value = azurerm_mysql_flexible_server.mysql_server.fqdn
}

output "db_name" {
  value = azurerm_mysql_flexible_server.mysql_server.name
}

output "server_name" {
  value = azurerm_mysql_flexible_server.mysql_server.name
}

output "server_id" {
  value = azurerm_mysql_flexible_server.mysql_server.id
}

output "db_version" {
  value = azurerm_mysql_flexible_server.mysql_server.version
}

output "storage" {
  value = azurerm_mysql_flexible_server.mysql_server.storage[0].size_gb 
}

output "sku_name" {
  value = azurerm_mysql_flexible_server.mysql_server.sku_name
}

output "db_user" {
  value = {
    for k,v in local.db_map : k => v.user
  }
}
