locals {
  cluster_name = var.app_env == "" ? var.app_name : "${var.app_name}-${var.app_env}"

  vpc_id             = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].vpc_id : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].vpc_id : module.remote_state_azure_cluster[0].vpc_id)
  cluster_name_parts = split("-", local.cluster_name)
  environment        = var.app_env

  enable_db          = try(var.sql_db.enable, false)
  db_list = distinct(concat(distinct([for key, value in var.services: value.db_name]), distinct([for key, value in var.cron_jobs: value.db_name])))

  common_tags        = merge(var.common_tags,
    tomap({
      project     = try(var.standard_tags.project != null ? var.standard_tags.project : local.cluster_name ,local.cluster_name)
      provisioner = try(var.standard_tags.provisioner != null ? var.standard_tags.provisioner : "zop-dev", "zop-dev")
    }))

  ext_rds_sg_cidr_block =  concat([data.aws_vpc.vpc.cidr_block], var.ext_rds_sg_cidr_block)

  subnet_ids          =   concat(local.db_subnets_ids,local.private_subnets_ids)
  private_subnets_ids = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].all_outputs.private_subnets_id : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].all_outputs.private_subnets_id : module.remote_state_azure_cluster[0].all_outputs.private_subnets_id)
  db_subnets_ids      = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].all_outputs.db_subnets_id : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].all_outputs.db_subnets_id : module.remote_state_azure_cluster[0].all_outputs.db_subnets_id)

  subnet_cidrs          =   concat(local.db_subnets_cidrs,local.private_subnets_cidrs)
  private_subnets_cidrs = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].private_subnets : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].private_subnets : module.remote_state_azure_cluster[0].private_subnets)
  db_subnets_cidrs      = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].db_subnets : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].db_subnets : module.remote_state_azure_cluster[0].db_subnets)
}

data "aws_vpc" "vpc" {
  id = local.vpc_id
}


module "rds" {
  source                = "../../../sql/aws-rds"
  cluster_name          = local.cluster_name
  namespace             = kubernetes_namespace.app_environments.metadata[0].name

  count                 =  local.enable_db == false ? 0 : 1

  enable_ssl                 = try(var.sql_db.enable_ssl,false)
  aws_region                 = var.app_region
  db_subnets                 = local.db_subnets_ids
  vpc_id                     = local.vpc_id
  ext_rds_sg_cidr_block      = var.rds_local_access == false ? local.subnet_cidrs : local.ext_rds_sg_cidr_block
  rds_name                   = "${local.cluster_name}-${var.namespace}-sql-db"
  read_replica               = try(var.sql_db.read_replica != null ? var.sql_db.read_replica : false)
  admin_user                 = var.sql_db.admin_user != null ? var.sql_db.admin_user : "postgresadmin"
  databases                  = local.db_list
  rds_type                   = var.sql_db.type != null ? var.sql_db.type : "postgresql"
  allocated_storage          = var.sql_db.disk_size != null ? var.sql_db.disk_size : 10
  instance_class             = var.sql_db.node_type != null ? var.sql_db.node_type : "db.t3.small"
  multi_az                   = var.sql_db.multi_az != null ? var.sql_db.multi_az : false
  read_replica_multi_az      = var.sql_db.multi_az != null ? (var.sql_db.multi_az == true && var.sql_db.read_replica_multi_az != null ? var.sql_db.read_replica_multi_az : false) : false
  deletion_protection        = var.sql_db.deletion_protection != null ? var.sql_db.deletion_protection : true
  apply_immediately          = var.sql_db.apply_changes_immediately != null ? var.sql_db.apply_changes_immediately : false
  max_allocated_storage      = var.sql_db.rds_max_allocated_storage != null ? var.sql_db.rds_max_allocated_storage : ( var.sql_db.disk_size == null ? 200 : ( var.sql_db.disk_size >= 200 ? var.sql_db.disk_size + 100 : 200))
  monitoring_interval        = try(var.sql_db.monitoring_interval != null ? var.sql_db.monitoring_interval : 0)
  log_min_duration_statement = var.sql_db.log_min_duration_statement  != null ? var.sql_db.log_min_duration_statement  : -1
  iops                       = var.sql_db.provisioned_iops != null ? var.sql_db.provisioned_iops : 0
  postgresql_engine_version  = var.sql_db.engine_version != null ? var.sql_db.engine_version : "16.3"

  tags                  = local.common_tags
}



resource "kubernetes_service" "db_service" {
  count       =  var.sql_db == null ? 0 : 1
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
  additonal_secrets_map = tomap({
    for secret_key in var.custom_namespace_secrets : "${var.namespace}-${secret_key}"=> {
      namespace = var.namespace
    }
  })
}