locals {
  cluster_prefix = var.cluster_prefix != "" ? var.cluster_prefix : "${var.provider_id}/${var.app_env}/${var.app_name}"
  cluster_name = "${var.app_name}-${var.app_env}"
} 

terraform {
  backend "gcs" {}
}

data "google_compute_network" "vpc" {
  name    = var.vpc
}

data "terraform_remote_state" "infra_output" {
  backend  = "gcs"
  config = {
    bucket   = var.bucket_name
    prefix   = "${local.cluster_prefix}/terraform.tfstate"
  }
} 

data "google_container_cluster" "gke" {
  name     = data.terraform_remote_state.infra_output.outputs.cluster_name
  location = var.app_region
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${data.terraform_remote_state.infra_output.outputs.kubernetes_endpoint}"
  token                  = data.google_client_config.default.access_token
  client_certificate     = data.google_container_cluster.gke.master_auth.0.client_certificate
  client_key             = data.google_container_cluster.gke.master_auth.0.client_key
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infra_output.outputs.ca_certificate)
}

resource "google_compute_firewall" "redis-firewall" {
  name       = "${local.cluster_name}-${var.namespace}-firewall"
  network    = data.google_compute_network.vpc.self_link

  direction  = "INGRESS"

  allow {
    protocol  = "tcp"
    ports     = ["6379"]
  }

  source_ranges = []
}

# count specifies if `var.num_node_groups` is greater than 1 it creates redis in cluster mode
resource "google_redis_instance" "redis_cluster" {
  count                   = var.redis.replica_count > 1 ? 1 : 0
  provider                = google-beta
  project                 = var.provider_id
  name                    = var.redis.name != "" && var.redis.name != null ? var.redis.name : "${local.cluster_name}-${var.namespace}"
  tier                    = var.redis.machine_type
  memory_size_gb          = var.redis.memory_size
  connect_mode            = var.redis.connect_mode
  region                  = var.app_region
  authorized_network      = data.google_compute_network.vpc.self_link
  redis_version           = var.redis.redis_version
  replica_count           = var.redis.replica_count
  read_replicas_mode      = "READ_REPLICAS_ENABLED"
  labels                  = var.labels
}

# count specifies if `var.replica_count` is not greater than 1 it creates redis in non cluster mode
resource "google_redis_instance" "redis" {
  count                   = var.redis.replica_count > 1 ? 0 : 1
  provider                = google-beta
  project                 = var.provider_id
  name                    = var.redis.name != "" && var.redis.name != null ? var.redis.name : "${local.cluster_name}-${var.namespace}"
  tier                    = var.redis.machine_type
  memory_size_gb          = var.redis.memory_size
  connect_mode            = var.redis.connect_mode
  region                  = var.app_region
  authorized_network      = data.google_compute_network.vpc.self_link
  redis_version           = var.redis.redis_version
  labels                  = var.labels
}

resource "random_string" "redis_name_suffix" {
  length   = 16
  numeric  = false
  lower    = true
  upper    = false
  special  = false
}

resource "kubernetes_service" "redis_service" {
  metadata {
    name      = var.redis.name != "" && var.redis.name != null ? "${var.redis.name}-${var.namespace}-redis" : "${var.namespace}-redis"
    namespace = var.namespace 
  }
  spec {
    type         = "ExternalName"
    external_name = var.redis.replica_count > 1 ? google_redis_instance.redis_cluster.0.host : google_redis_instance.redis.0.host
    port {
      port = var.redis.replica_count > 1 ? google_redis_instance.redis_cluster.0.port : google_redis_instance.redis.0.port
    }
  }
}