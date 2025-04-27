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
  subnet_id             = module.remote_state_oci_cluster.0.db_subnets
  availability_domain   = data.oci_identity_availability_domains.availability_domains.availability_domains[0].name
  cluster_name          = local.cluster_name
  vault_id              = module.remote_state_oci_cluster.0.kms_vault_id
  key_id                = module.remote_state_oci_cluster.0.kms_key_id

  mysql_db_system_name  = each.key
  databases             = try(local.database_map[each.key], [])

  administrator_login   = each.value.admin_user != null ? each.value.admin_user : "mysqladmin"
  storage               = each.value.storage != null ? each.value.storage : 50
  storage_scaling       = each.value.storage_scaling != null ? each.value.storage_scaling : true
  mysql_shape_name      = each.value.storage_tier != null ? each.value.storage_tier : "MySQL.2"
  deletion_protection   = each.value.deletion_protection != null ? each.value.deletion_protection : false 
  backup_retention_days = each.value.backup_retention_days != null ? each.value.backup_retention_days : 7
  read_replica          = each.value.read_replica 

  tags  = local.common_tags
}