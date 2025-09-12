resource "azurerm_mysql_flexible_server" "mysql_server" {
  name                      = var.mysql_server_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  administrator_login       = var.administrator_login
  administrator_password    = azurerm_key_vault_secret.mysql_db_secret.value
  backup_retention_days     = var.backup_retention_days
  sku_name                  = var.sku_name
  version                   = var.mysql_version

  storage {
    size_gb = var.storage
    auto_grow_enabled = var.storage_scaling
    iops = var.iops
    io_scaling_enabled = var.io_scaling_enabled
  }

  tags = merge(var.tags,
    tomap({
      "Name" = var.mysql_server_name
    })
  )
  lifecycle {
    ignore_changes = [
     zone,
    ]
  }
}

resource "azurerm_mysql_flexible_database" "mysql_db" {
  for_each = local.db_map
  name                         = each.value.db_name
  resource_group_name          = var.resource_group_name
  server_name                  = azurerm_mysql_flexible_server.mysql_server.name
  charset                      = local.charset
  collation                    = local.collation
}

resource "azurerm_mysql_flexible_server_configuration" "mysql_parameter_group" {
  name                    = "require_secure_transport"
  resource_group_name     = var.resource_group_name
  server_name             = azurerm_mysql_flexible_server.mysql_server.name
  value                   = "OFF"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "mysql_firewall" {
  name                    = "${var.cluster_name}-${var.namespace}-mysql-firewall"
  resource_group_name     = var.resource_group_name
  server_name             = azurerm_mysql_flexible_server.mysql_server.name
  start_ip_address        = "0.0.0.0"
  end_ip_address          = "255.255.255.255"
}

resource "azurerm_mysql_flexible_server" "mysql_read_replica" {
  count                     = var.read_replica ? 1 : 0
  name                      = "mysql-read-replica-${var.mysql_server_name}"
  location                  = var.location
  resource_group_name       =  var.resource_group_name
  version                   =  var.mysql_version
  create_mode               =  "Replica"
  source_server_id          =  azurerm_mysql_flexible_server.mysql_server.id
}