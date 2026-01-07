data "azurerm_virtual_network" "vnet" {
  count               = var.vpc != "" ? 1 : 0
  name                = var.vpc
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "db_subnet" {
  count                = var.vpc != "" && var.subnet != "" ? 1 : 0
  name                 = var.subnet
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet[0].name
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

  # VNet integration
  # When VNet is provided, automatically disable public access (like AWS/GCP)
  delegated_subnet_id              = var.vpc != "" && var.subnet != "" ? data.azurerm_subnet.db_subnet[0].id : null
  public_network_access_enabled    = var.vpc != "" && var.subnet != "" ? false : true

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
  count             = var.vpc == "" || var.subnet == "" ? 1 : 0
  name              = "${var.cluster_name}-${var.namespace}-postgres-firewall"
  server_id         = azurerm_postgresql_flexible_server.postgres_server.id
  start_ip_address  = "0.0.0.0"
  end_ip_address    = "255.255.255.255"
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