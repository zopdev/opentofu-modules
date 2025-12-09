locals {
  cluster_name = var.app_env == "" ? var.app_name : "${var.app_name}-${var.app_env}"

  vpc_id = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].vpc_id : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].vpc_id : module.remote_state_azure_cluster[0].vpc_id)

  enable_db = try(var.sql_db.enable, false)
  db_list   = distinct(concat(distinct([for key, value in var.services : value.db_name]), distinct([for key, value in var.cron_jobs : value.db_name])))

  common_tags = merge(var.common_tags,
    tomap({
      project     = try(var.standard_tags.project != null ? var.standard_tags.project : local.cluster_name, local.cluster_name)
      provisioner = try(var.standard_tags.provisioner != null ? var.standard_tags.provisioner : "zop-dev", "zop-dev")
  }))

  ext_rds_sg_cidr_block = concat([data.aws_vpc.vpc.cidr_block], var.ext_rds_sg_cidr_block)

  db_subnets_ids = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].all_outputs.db_subnets_id : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].all_outputs.db_subnets_id : module.remote_state_azure_cluster[0].all_outputs.db_subnets_id)

  subnet_cidrs          = concat(local.db_subnets_cidrs, local.private_subnets_cidrs)
  private_subnets_cidrs = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].private_subnets : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].private_subnets : module.remote_state_azure_cluster[0].private_subnets)
  db_subnets_cidrs      = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].db_subnets : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].db_subnets : module.remote_state_azure_cluster[0].db_subnets)

  grouped_database_map = merge(
    {
      for service_key, service_value in var.services :
      service_value.datastore_configs.name => [
        service_value.datastore_configs.databse
      ]...
      if try(service_value.datastore_configs.name, null) != null &&
      try(service_value.datastore_configs.databse, null) != null
    },
    {
      for cron_key, cron_value in var.cron_jobs :
      cron_value.datastore_configs.name => [
        cron_value.datastore_configs.databse
      ]...
      if try(cron_value.datastore_configs.name, null) != null &&
      try(cron_value.datastore_configs.databse, null) != null
    }
  )

  # Remove duplicates in each list
  database_map = {
    for k, v in local.grouped_database_map :
    k => distinct(flatten(v))
  }
}

data "aws_vpc" "vpc" {
  id = local.vpc_id
}


module "rds" {
  source       = "../../../sql/aws-rds"
  cluster_name = local.cluster_name
  namespace    = kubernetes_namespace.app_environments.metadata[0].name

  count = local.enable_db == false ? 0 : 1

  enable_ssl                 = try(var.sql_db.enable_ssl, false)
  aws_region                 = var.app_region
  db_subnets                 = local.db_subnets_ids
  vpc_id                     = local.vpc_id
  ext_rds_sg_cidr_block      = var.rds_local_access == false ? local.subnet_cidrs : local.ext_rds_sg_cidr_block
  rds_name                   = "${local.cluster_name}-${var.namespace}-sql-db"
  read_replica               = try(var.sql_db.read_replica != null ? var.sql_db.read_replica : false)
  admin_user                 = var.sql_db.admin_user != null ? var.sql_db.admin_user : "postgresadmin"
  databases                  = local.db_list
  rds_type                   = var.sql_db.type != null ? var.sql_db.type : "postgresql"
  allocated_storage          = var.sql_db.disk_size != null ? var.sql_db.disk_size : 20
  instance_class             = var.sql_db.node_type != null ? var.sql_db.node_type : "db.t3.small"
  multi_az                   = var.sql_db.multi_az != null ? var.sql_db.multi_az : false
  read_replica_multi_az      = var.sql_db.multi_az != null ? (var.sql_db.multi_az == true && var.sql_db.read_replica_multi_az != null ? var.sql_db.read_replica_multi_az : false) : false
  deletion_protection        = var.sql_db.deletion_protection != null ? var.sql_db.deletion_protection : true
  apply_immediately          = var.sql_db.apply_changes_immediately != null ? var.sql_db.apply_changes_immediately : false
  max_allocated_storage      = var.sql_db.rds_max_allocated_storage != null ? var.sql_db.rds_max_allocated_storage : (var.sql_db.disk_size == null ? 200 : (var.sql_db.disk_size >= 200 ? var.sql_db.disk_size + 100 : 200))
  monitoring_interval        = try(var.sql_db.monitoring_interval != null ? var.sql_db.monitoring_interval : 0)
  log_min_duration_statement = var.sql_db.log_min_duration_statement != null ? var.sql_db.log_min_duration_statement : -1
  storage_tier               = var.sql_db.storage_tier != null ? var.sql_db.storage_tier : "gp3"
  postgresql_engine_version  = var.sql_db.engine_version != null ? var.sql_db.engine_version : "16.3"

  tags = local.common_tags
}



resource "kubernetes_service" "db_service" {
  count = var.sql_db == null ? 0 : 1
  metadata {
    name      = "${var.namespace}-rds"
    namespace = "db"
  }
  spec {
    type          = "ExternalName"
    external_name = split(":", module.rds[0].db_url)[0]
    port {
      port = module.rds[0].db_port
    }
  }
}

locals {
}

module "rds_v2" {
  source       = "../../../sql/aws-rds"
  for_each     = var.sql_list
  cluster_name = local.cluster_name
  namespace    = kubernetes_namespace.app_environments.metadata[0].name

  enable_ssl                 = try(each.value.enable_ssl, false)
  aws_region                 = var.app_region
  db_subnets                 = local.db_subnets_ids
  vpc_id                     = local.vpc_id
  ext_rds_sg_cidr_block      = var.rds_local_access == false ? local.subnet_cidrs : local.ext_rds_sg_cidr_block
  rds_name                   = each.key
  read_replica               = try(each.value.read_replica != null ? each.value.read_replica : false)
  admin_user                 = each.value.admin_user != null ? each.value.admin_user : "postgresadmin"
  databases                  = try(local.database_map[each.key], [])
  rds_type                   = each.value.type != null ? each.value.type : "postgresql"
  allocated_storage          = each.value.disk_size != null ? each.value.disk_size : 20
  instance_class             = each.value.node_type != null ? each.value.node_type : "db.t3.small"
  multi_az                   = each.value.multi_az != null ? each.value.multi_az : false
  read_replica_multi_az      = each.value.multi_az != null ? (each.value.multi_az == true && each.value.read_replica_multi_az != null ? each.value.read_replica_multi_az : false) : false
  deletion_protection        = each.value.deletion_protection != null ? each.value.deletion_protection : true
  apply_immediately          = each.value.apply_changes_immediately != null ? each.value.apply_changes_immediately : false
  max_allocated_storage      = each.value.rds_max_allocated_storage != null ? each.value.rds_max_allocated_storage : (each.value.disk_size == null ? 200 : (each.value.disk_size >= 200 ? each.value.disk_size + 100 : 200))
  monitoring_interval        = try(each.value.monitoring_interval != null ? each.value.monitoring_interval : 0)
  log_min_duration_statement = each.value.log_min_duration_statement != null ? each.value.log_min_duration_statement : -1
  storage_tier               = each.value.storage_tier != null ? each.value.storage_tier : "gp3"
  postgresql_engine_version  = each.value.engine_version != null ? each.value.engine_version : "16.1"
  multi_ds                   = true

  tags = local.common_tags
}

resource "kubernetes_service" "db_service_v2" {
  for_each = var.sql_list

  metadata {
    name      = "${each.key}-rds"
    namespace = "db"
  }

  spec {
    type          = "ExternalName"
    external_name = split(":", module.rds_v2[each.key].db_url)[0]
    port {
      port = module.rds_v2[each.key].db_port
    }
  }
}