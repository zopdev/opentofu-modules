locals {
  cluster_name = var.app_env == "" ? var.app_name : "${var.app_name}-${var.app_env}"
  cluster_name_parts = split("-", local.cluster_name)
  environment        = var.app_env

  secondary_ip = [for subnet in data.google_compute_subnetwork.app_subnet.secondary_ip_range : subnet.ip_cidr_range]
  ext_rds_sg_cidr_block = concat([data.google_compute_subnetwork.app_subnet.ip_cidr_range], local.secondary_ip , var.ext_rds_sg_cidr_block)

  enable_db = try(var.sql_db.enable, false)
  db_list = distinct(concat(distinct([for key, value in var.services: value.db_name]), distinct([for key, value in var.cron_jobs: value.db_name])))

  common_tags        = merge(var.common_tags,
    tomap({
      project     = try(var.standard_tags.project != null ? var.standard_tags.project : local.cluster_name ,local.cluster_name)
      provisioner = try(var.standard_tags.provisioner != null ? var.standard_tags.provisioner : "zop-dev", "zop-dev")
    }))

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
)
}

data "google_project" "this" {}

data "google_client_config" "default" {}

data "google_compute_network" "vpc" {
  name    = var.vpc
}

data "google_compute_subnetwork" "app_subnet" {
  name   = var.subnet
  region = var.app_region
}

module "sql_db" {
  source         = "../../../sql/gcp-sql"
  count                 =  local.enable_db == true ? 1 : 0

  project_id            = var.provider_id
  project_number        = data.google_project.this.number
  region                = var.app_region
  app_uid               = regex("[a-z][-a-z0-9]{4,29}", random_string.namespace_uid.result)
  vpc_name              = data.google_compute_network.vpc.self_link
  cluster_name          = local.cluster_name
  namespace             = var.namespace
  sql_name              = "${local.cluster_name}-${var.namespace}-${var.sql_db.type != null ? (var.sql_db.type == "postgresql" ? "postgresql" : "sql") : "postgresql"}-db"
  sql_type              = var.sql_db.type != null ? var.sql_db.type : "postgresql"
  sql_version           = var.sql_db.sql_version != null ? var.sql_db.sql_version : ""
  databases             = local.db_list
  machine_type          = var.sql_db.machine_type != null ? var.sql_db.machine_type : "db-f1-micro"
  disk_size             = var.sql_db.disk_size != null ? var.sql_db.disk_size : 10
  disk_autoresize       = var.app_env == "prod" ? true : false
  read_replica          = var.sql_db.read_replica != null ? var.sql_db.read_replica : false
  deletion_protection   = var.sql_db.deletion_protection != null ? var.sql_db.deletion_protection : true
  activation_policy     = var.sql_db.activation_policy != null ? var.sql_db.activation_policy : "ALWAYS"
  db_collation          = var.sql_db.db_collation != null ? var.sql_db.db_collation : (var.sql_db.type == "mysql" ? "utf8_general_ci" : "en_US.UTF8")
  availability_type     = var.sql_db.availability_type != null ? var.sql_db.availability_type : "ZONAL"
  ext_rds_sg_cidr_block = local.ext_rds_sg_cidr_block
  labels                = local.common_tags
  enable_ssl            = var.sql_db.enable_ssl != null ? var.sql_db.enable_ssl : false
  depends_on            = [kubernetes_namespace.app_environments]
}


resource "kubernetes_service" "db_service" {
  count       =  var.sql_db == null ? 0 : 1
  metadata {
    name      = "${var.namespace}-sql"
    namespace = "db"
  }
  spec {
    type          = "ExternalName"
    external_name = module.sql_db[0].db_instance_ip
    port {
      port = module.sql_db[0].db_port
    }
  }
}

module "sql_db_v2" {
  source =  "../../../sql/gcp-sql"

  for_each = var.sql_list != null ? var.sql_list : {}

  project_id            = var.provider_id
  project_number        = data.google_project.this.number
  region                = var.app_region
  app_uid               = regex("[a-z][-a-z0-9]{4,29}", random_string.namespace_uid.result)
  vpc_name              = data.google_compute_network.vpc.self_link
  cluster_name          = local.cluster_name
  namespace             = var.namespace
  sql_name              = each.key
  sql_type              = each.value.type
  sql_version           = each.value.sql_version != null ? each.value.sql_version : ""
  databases             = try(local.database_map[each.key], [])
  machine_type          = each.value.machine_type != null ? each.value.machine_type : "db-f1-micro"
  disk_size             = each.value.disk_size != null ? each.value.disk_size : 10
  disk_autoresize       = var.app_env == "prod" ? true : false
  read_replica          = each.value.read_replica != null ? each.value.read_replica : false
  deletion_protection   = each.value.deletion_protection != null ? each.value.deletion_protection : true
  activation_policy     = each.value.activation_policy != null ? each.value.activation_policy : "ALWAYS"
  db_collation          = each.value.db_collation != null ? each.value.db_collation : (each.value.type == "mysql" ? "utf8_general_ci" : "en_US.UTF8")
  availability_type     = each.value.availability_type != null ? each.value.availability_type : "ZONAL"
  ext_rds_sg_cidr_block = local.ext_rds_sg_cidr_block
  labels                = local.common_tags
  enable_ssl            = each.value.enable_ssl != null ? each.value.enable_ssl : false
  multi_ds              = true
  depends_on            = [kubernetes_namespace.app_environments]
}

resource "kubernetes_service" "sql_db_service_v2" {

  for_each = var.sql_list != null ? var.sql_list : {}
  
  metadata {
    name      = "${each.key}-sql"
    namespace = "db"
  }
  spec {
    type          = "ExternalName"
    external_name = module.sql_db_v2[each.key].db_instance_ip
    port {
      port = module.sql_db_v2[each.key].db_port
    }
  }
}