locals {

  enable_db = try(var.sql_db.enable, false)
  db_list = distinct(concat(distinct([for key, value in var.services: value.db_name]), distinct([for key, value in var.cron_jobs: value.db_name])))

  grouped_database_map = {
    for pair in concat(
      [for _, s in var.services : {
        name   = try(s.datastore_configs.name, null)
        dbname = try(s.datastore_configs.databse, null)
      }],
      [for _, c in var.cron_jobs : {
        name   = try(c.datastore_configs.name, null)
        dbname = try(c.datastore_configs.databse, null)
      }]
    ) : pair.name => pair.dbname...
    if pair.name != null && pair.dbname != null
  }

  # optional: make db lists unique
  database_map = {
    for k, v in local.grouped_database_map :
    k => distinct(v)
  }
}

module "mysql" {
  source                     = "../../../sql/azure-mysql"
  resource_group_name        = var.resource_group_name
  location                   = var.app_region

  count                      = var.sql_db == null ? 0 : (var.sql_db.type == "mysql" ? 1 : 0)

  cluster_name               = local.cluster_name
  namespace                  = var.namespace
  mysql_server_name          = "${local.cluster_name}-${var.namespace}-mysql-server"
  databases                  = local.db_list
  sku_name                   = var.sql_db.sku_name != null ? var.sql_db.sku_name : "GP_Standard_D2ds_v4"
  administrator_login        = var.sql_db.admin_user != null ? var.sql_db.admin_user : "mysqladmin"
  storage                    = var.sql_db.storage != null ? var.sql_db.storage : 20
  storage_scaling            = var.sql_db.storage_scaling != null ? var.sql_db.storage_scaling : true
  iops                       = var.sql_db.iops != null ? var.sql_db.iops : 360
  io_scaling_enabled         = var.sql_db.iops_scaling != null ? var.sql_db.iops_scaling : false
  read_replica               = var.sql_db.read_replica != null ? var.sql_db.read_replica : false
  key_vault_id               = data.azurerm_key_vault.secrets.id
  tags                       = local.common_tags
}

resource "kubernetes_service" "mysql_db_service" {
  count = var.sql_db == null ? 0 : (var.sql_db.type == "mysql" ? 1 : 0)

  metadata {
    name      = "${var.namespace}-sql"
    namespace = "db"
  }
  spec {
    type          = "ExternalName"
    external_name = module.mysql[0].db_url
    port {
      port = module.mysql[0].db_port
    }
  }
}


module "postgresql" {
  source                     = "../../../sql/azure-postgres"
  resource_group_name        = var.resource_group_name
  location                   = var.app_region

  count                      = var.sql_db == null ? 0 : (var.sql_db.type == "postgresql" ? 1 : 0)

  cluster_name               = local.cluster_name
  namespace                  = var.namespace
  postgres_server_name       = "${local.cluster_name}-${var.namespace}-postgres-server"
  databases                  = local.db_list
  sku_name                   = var.sql_db.sku_name != null ? var.sql_db.sku_name : "GP_Standard_D2s_v3"
  administrator_login        = var.sql_db.admin_user != null ? var.sql_db.admin_user : "postgresqladmin"
  storage_mb                 = var.sql_db.storage != null ? var.sql_db.storage : 32768
  storage_scaling            = var.sql_db.storage_scaling != null ? var.sql_db.storage_scaling : false
  storage_tier               = var.sql_db.storage_tier != null ? var.sql_db.storage_tier : "P4"
  read_replica               = var.sql_db.read_replica != null ? var.sql_db.read_replica : false
  key_vault_id               = data.azurerm_key_vault.secrets.id
  enable_ssl                 = var.sql_db.enable_ssl != null ? var.sql_db.enable_ssl : false

  tags                       = merge(local.common_tags,
    tomap({
      "Name" = "${local.cluster_name}-${var.namespace}-postgres-server"
    })
  )
}

resource "kubernetes_service" "postgresql_db_service" {
  count = var.sql_db == null ? 0 : (var.sql_db.type == "postgresql" ? 1 : 0)

  metadata {
    name      = "${var.namespace}-sql"
    namespace = "db"
  }
  spec {
    type          = "ExternalName"
    external_name = module.postgresql[0].db_url
    port {
      port = module.postgresql[0].db_port
    }
  }
}

module "mysql_v2" {
  source                     = "../../../sql/azure-mysql"
  resource_group_name        = var.resource_group_name
  location                   = var.app_region

  for_each = var.sql_list != null ? {
    for key, value in var.sql_list : key => value if value.type == "mysql"
  } : {}
  
  cluster_name               = local.cluster_name
  namespace                  = var.namespace
  mysql_server_name          = each.key
  databases                  = try(local.database_map[each.key], [])

  sku_name                   = each.value.sku_name != null ? each.value.sku_name : "GP_Standard_D2ds_v4"
  administrator_login        = each.value.admin_user != null ? each.value.admin_user : "mysqladmin"
  storage                    = each.value.storage != null ? each.value.storage : 20
  storage_scaling            = each.value.storage_scaling != null ? each.value.storage_scaling : true
  iops                       = each.value.iops != null ? each.value.iops : 360
  io_scaling_enabled         = each.value.iops_scaling != null ? each.value.iops_scaling : false
  read_replica               = each.value.read_replica != null ? each.value.read_replica : false
  multi_ds                   = true
  key_vault_id               = data.azurerm_key_vault.secrets.id
  tags                       = local.common_tags
  mysql_version              = each.value.version != null ? each.value.version == "" ? "8.0" : "8.0"
}


resource "kubernetes_service" "mysql_db_service_v2" {
  for_each = var.sql_list != null ? {
    for key, value in var.sql_list : key => value if value.type == "mysql"
  } : {}
  
  metadata {
    name      = "${each.key}-sql"
    namespace = "db"
  }

  spec {
    type          = "ExternalName"
    external_name = module.mysql_v2[each.key].db_url
    port {
      port = module.mysql_v2[each.key].db_port
    }
  }
}

module "postgres_v2" {
  source                     = "../../../sql/azure-postgres"
  resource_group_name        = var.resource_group_name
  location                   = var.app_region

  for_each = var.sql_list != null ? {
    for key, value in var.sql_list : key => value if value.type == "postgresql"
  } : {}

  cluster_name               = local.cluster_name
  namespace                  = var.namespace
  postgres_server_name       = each.key
  databases                  = try(local.database_map[each.key], [])

  sku_name                   = each.value.sku_name != null ? each.value.sku_name : "GP_Standard_D2s_v3"
  administrator_login        = each.value.admin_user != null ? each.value.admin_user : "postgresqladmin"
  storage_mb                 = each.value.storage != null ? each.value.storage : 32768
  storage_scaling            = each.value.storage_scaling != null ? each.value.storage_scaling : false
  storage_tier               = each.value.storage_tier != null ? each.value.storage_tier : "P4"
  read_replica               = each.value.read_replica != null ? each.value.read_replica : false
  key_vault_id               = data.azurerm_key_vault.secrets.id
  multi_ds                   = true
  enable_ssl                 = each.value.enable_ssl != null ? each.value.enable_ssl : false

  tags                       = merge(local.common_tags,
    tomap({
      "Name" = each.key
    })
  )
}

resource "kubernetes_service" "postgres_v2_db_service" {
  for_each = var.sql_list != null ? {
    for key, value in var.sql_list : key => value if value.type == "postgresql"
  } : {}

  metadata {
    name      = "${each.key}-sql"
    namespace = "db"
  }

  spec {
    type          = "ExternalName"
    external_name = module.postgres_v2[each.key].db_url
    port {
      port = module.postgres_v2[each.key].db_port
    }
  }
}
