locals {
  vnet_enabled = var.vpc != ""
  subnet_name  = local.vnet_enabled ? "${var.vpc}-mysql-subnet" : ""
}

data "azurerm_virtual_network" "vnet" {
  count               = local.vnet_enabled ? 1 : 0
  name                = var.vpc
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "db_subnet" {
  count                = local.vnet_enabled ? 1 : 0
  name                 = local.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet[0].name
}

# Reference existing Private DNS Zone created by account-setup module
data "azurerm_private_dns_zone" "mysql" {
  count               = local.vnet_enabled ? 1 : 0
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_mysql_flexible_server" "mysql_server" {
  name                          = var.mysql_server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  administrator_login           = var.administrator_login
  administrator_password        = azurerm_key_vault_secret.mysql_db_secret.value
  backup_retention_days         = var.backup_retention_days
  sku_name                      = var.sku_name

  # VNet integration
  delegated_subnet_id           = local.vnet_enabled ? data.azurerm_subnet.db_subnet[0].id : null
  private_dns_zone_id           = local.vnet_enabled ? data.azurerm_private_dns_zone.mysql[0].id : null

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
  charset                      = var.charset
  collation                    = var.collation
}

resource "azurerm_mysql_flexible_server_configuration" "mysql_parameter_group" {
  count                   = var.enable_ssl == false ? 1 : 0
  name                    = "require_secure_transport"
  resource_group_name     = var.resource_group_name
  server_name             = azurerm_mysql_flexible_server.mysql_server.name
  value                   = "OFF"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "mysql_firewall" {
  count                   = local.vnet_enabled ? 0 : 1
  name                    = "${var.cluster_name}-${var.namespace}-mysql-firewall"
  resource_group_name     = var.resource_group_name
  server_name             = azurerm_mysql_flexible_server.mysql_server.name
  start_ip_address        = "0.0.0.0"
  end_ip_address          = "0.0.0.0"
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