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
