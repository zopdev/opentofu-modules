locals {
  vnet_enabled = var.vpc != ""
  subnet_name  = local.vnet_enabled ? "${var.vpc}-postgresql-subnet" : ""
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
data "azurerm_private_dns_zone" "postgres" {
  count               = local.vnet_enabled ? 1 : 0
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_postgresql_flexible_server" "postgres_server" {
  name                             = var.postgres_server_name
  location                         = var.location
  resource_group_name              = var.resource_group_name
  administrator_login              = var.administrator_login
  administrator_password           = azurerm_key_vault_secret.postgres_db_secret.value
  version                          = var.postgres_version
  sku_name                         = var.sku_name
  storage_mb                       = var.storage_mb
  auto_grow_enabled                = var.storage_scaling
  storage_tier                     = var.storage_tier
  backup_retention_days            = var.backup_retention_days
  geo_redundant_backup_enabled     = true
  public_network_access_enabled    = local.vnet_enabled ? false : true

  # VNet integration
  # When delegated_subnet_id is provided, Azure automatically disables public network access
  delegated_subnet_id = local.vnet_enabled ? data.azurerm_subnet.db_subnet[0].id : null
  private_dns_zone_id = local.vnet_enabled ? data.azurerm_private_dns_zone.postgres[0].id : null

  tags = merge(var.tags,
    tomap({
      "Name" = var.postgres_server_name
    })
  )
  lifecycle {
    ignore_changes = [
      zone,
    ]
  }
}

resource "azurerm_postgresql_flexible_server_database" "postgres_db" {
  for_each = local.db_map
  name                         = each.value.db_name
  server_id           = azurerm_postgresql_flexible_server.postgres_server.id
  charset             = var.charset
  collation           = var.collation
}

resource "azurerm_postgresql_flexible_server_configuration" "ssl_parameter_group" {
  count        = var.enable_ssl == false ? 1 : 0
  name         = "require_secure_transport"
  server_id    = azurerm_postgresql_flexible_server.postgres_server.id
  value        = "OFF"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "postgres_firewall" {
  count               = local.vnet_enabled ? 0 : 1
  name                = "${var.cluster_name}-${var.namespace}-postgres-firewall"
  server_id           = azurerm_postgresql_flexible_server.postgres_server.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_postgresql_flexible_server" "postgresql_replica_server" {
  count                  = var.read_replica == true ? 1 : 0
  name                   = "postgresql-read-replica-${var.postgres_server_name}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.postgres_version
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password
  storage_mb             = var.storage_mb
  sku_name               = var.sku_name
  create_mode            = "Replica"
  source_server_id       = azurerm_postgresql_flexible_server.postgres_server.id
}
