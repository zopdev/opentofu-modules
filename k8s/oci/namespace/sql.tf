locals {
  database_map = merge(
  {
    for service_key, service_value in var.services :
      service_value.datastore_configs.name => [
        service_value.datastore_configs.database
      ]
      if try(service_value.datastore_configs.name, null) != null &&
         try(service_value.datastore_configs.database, null) != null
  },
  {
    for cron_key, cron_value in var.cron_jobs :
      cron_value.datastore_configs.name => [
        cron_value.datastore_configs.database
      ]
      if try(cron_value.datastore_configs.name, null) != null &&
         try(cron_value.datastore_configs.database, null) != null
  }
)
}

data "oci_identity_availability_domains" "availability_domains" {
    compartment_id = var.provider_id
}

module "sql_db" {
  source         = "../../../sql/oci-mysql"
  
  for_each = var.sql_list != null ? {
    for key, value in var.sql_list : key => value if value.type == "mysql"
  } : {}
  
  namespace             = var.namespace
  provider_id           = var.provider_id
  subnet_id             = local.db_subnets
  availability_domain   = data.oci_identity_availability_domains.availability_domains.availability_domains[0].name
  cluster_name          = local.cluster_name
  vault_id              = local.kms_vault_id
  key_id                = local.kms_key_id

  mysql_db_system_name  = each.key
  databases             = try(local.database_map[each.key], [])

  administrator_login   = each.value.admin_user != null ? each.value.admin_user : "mysqladmin"
  storage               = each.value.storage != null ? each.value.storage : 50
  storage_scaling       = each.value.storage_scaling != null ? each.value.storage_scaling : true
  mysql_shape_name      = each.value.storage_tier != null ? each.value.storage_tier : "MySQL.2"
  deletion_protection   = each.value.deletion_protection != null ? each.value.deletion_protection : false 
  backup_retention_days = each.value.backup_retention_days != null ? each.value.backup_retention_days : 7
  read_replica          = each.value.read_replica 
  enable_ssl            = each.value.enable_ssl != null ? each.value.enable_ssl : false

  tags  = local.common_tags
}

resource "kubernetes_service" "sql_db_service" {
  for_each = var.sql_list != null ? {
    for key, value in var.sql_list : key => value if value.type == "mysql"
  } : {}

  metadata {
    name      = "${each.key}-sql"
    namespace = "db"
  }

  spec {
    cluster_ip = "None" 
    port {
      port     = module.sql_db[each.key].db_port
      protocol = "TCP"
    }
  }
}

resource "kubernetes_endpoints" "sql_db_endpoint" {
  for_each = var.sql_list != null ? {
    for key, value in var.sql_list : key => value if value.type == "mysql"
  } : {}

  metadata {
    name      = "${each.key}-sql"
    namespace = "db"
  }

  subset {
    address {
      ip = module.sql_db[each.key].db_url  
    }
    port {
      port     = module.sql_db[each.key].db_port
      protocol = "TCP"
    }
  }
  depends_on = [ kubernetes_service.sql_db_service ]
}

module "psql_db" {
  source         = "../../../sql/oci-postgres"
  
  for_each = var.sql_list != null ? {
    for key, value in var.sql_list : key => value if value.type == "postgres"
  } : {}
  
  namespace               = var.namespace
  provider_id             = var.provider_id
  subnet_id               = local.db_subnets
  availability_domain     = data.oci_identity_availability_domains.availability_domains.availability_domains[0].name
  cluster_name            = local.cluster_name
  vault_id                = local.kms_vault_id
  key_id                  = local.kms_key_id

  postgres_db_system_name = each.key
  databases               = try(local.database_map[each.key], [])

  administrator_login     = each.value.admin_user != null ? each.value.admin_user : "postgresadmin"
  postgres_shape_name     = each.value.storage_tier != null ? each.value.storage_tier : "PostgreSQL.VM.Standard.E4.Flex.2.32GB"
  psql_version            = each.value.psql_version != null ? each.value.psql_version : 14
  iops                    = each.value.iops !=null ? each.value.iops : 75000
  system_type             = each.value.system_type !=null ? each.value.system_type : "OCI_OPTIMIZED_STORAGE"
  instance_count          = each.value.read_replica ? 1 : 2
  
  tags  = local.common_tags
}

resource "kubernetes_service" "psql_db_service" {
  for_each = var.sql_list != null ? {
    for key, value in var.sql_list : key => value if value.type == "postgres"
  } : {}
  
  metadata {
    name      = "${each.key}-psql"
    namespace = "db"
  }
  
  spec {
    type = "ClusterIP"
    cluster_ip = "None"  
    
    port {
      name        = "postgresql"
      port        = module.psql_db[each.key].db_port
      protocol    = "TCP"
      target_port = module.psql_db[each.key].db_port
    }
  }
}

resource "kubernetes_endpoints" "psql_db_endpoint" {
  for_each = var.sql_list != null ? {
    for key, value in var.sql_list : key => value if value.type == "postgres"
  } : {}
  
  metadata {
    name      = "${each.key}-psql"
    namespace = "db"
  }
  
  subset {
    address {
      ip = module.psql_db[each.key].db_url  
    }
    address {
      ip = "242.42.164.63" 
    }
    
    port {
      name     = "postgresql"
      port     = module.psql_db[each.key].db_port
      protocol = "TCP"
    }
  }

  depends_on = [kubernetes_service.psql_db_service]
}