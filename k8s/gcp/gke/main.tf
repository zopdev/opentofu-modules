data "google_project" "this" {
}

data "google_client_config" "default" {}

data "google_compute_network" "vpc" {
  name    = var.vpc
}

data "google_compute_subnetwork" "app_subnet" {
  name   = var.subnet
  region = var.app_region
}

resource "random_string" "cluster_svc_account" {
  length   = 16
  numeric  = true
  lower    = true
  upper    = false
  special  = false
}

locals {
  cluster_name = var.app_env == "" ? var.app_name : "${var.app_name}-${var.app_env}"
  cluster_name_parts = split("-", local.cluster_name)
  environment        = var.app_env
  namespaces = [for namespace in var.namespace_folder_list : split("/", namespace)[0]]
  node_port    = 32443 # Node port which will be used by LB for exposure

  cidr_blocks  = try(var.accessibility.cidr_blocks != null ? var.accessibility.cidr_blocks : ["10.0.0.0/8"],  ["10.0.0.0/8"] )

  cluster_networks = concat([
    for cidr in local.cidr_blocks : {
      cidr_block = cidr
      display_name = "${cidr} cidr block"
    }
  ])

  cluster_service_account_name = regex("[a-z][-a-z0-9]{4,29}", random_string.cluster_svc_account.result )

  common_tags        = merge(var.common_tags,
    tomap({
      project     = try(var.standard_tags.project != null ? var.standard_tags.project : local.cluster_name ,local.cluster_name)
      provisioner = try(var.standard_tags.provisioner != null ? var.standard_tags.provisioner : "zop-dev", "zop-dev")
    }))

}

module "gke" {
  source                      = "../../../gke"
  project_id                  = var.provider_id
  network_project_id          = var.provider_id
  name                        = local.cluster_name
  kubernetes_version          = "1.31.9"
  regional                    = true
  zones                       = try(var.node_config.availability_zones, [])
  region                      = var.app_region
  network                     = data.google_compute_network.vpc.name
  subnetwork                  = data.google_compute_subnetwork.app_subnet.name
  ip_range_pods               = ""
  ip_range_services           = ""
  create_service_account      = false
  enable_cost_allocation      = true
  enable_binary_authorization = false
  remove_default_node_pool    = true
  logging_service             = "none"
  release_channel             = "UNSPECIFIED"
  deletion_protection         = var.cluster_deletion_protection

  cluster_autoscaling  = {
    enabled    = false
    autoscaling_profile = "BALANCED"
    max_cpu_cores       = 0
    min_cpu_cores       = 0
    max_memory_gb       = 0
    min_memory_gb       = 0
    gpu_resources       = []
    auto_repair         = true
    auto_upgrade        = false
  }

  master_authorized_networks = local.cluster_networks

    node_pools = [
      {
        name               = "node-pool"
        image_type         = "ubuntu_containerd"
        machine_type       = var.default_node_config.node_type
        min_count          = var.default_node_config.min_count
        max_count          = var.default_node_config.max_count
        preemptible        = var.default_node_config.preemptible
        service_account    = "${data.google_project.this.number}-compute@developer.gserviceaccount.com"
      },
      {
        name               = "deployment-pool"
        image_type         = "ubuntu_containerd"
        machine_type       = var.deployment_node_config.node_type
        min_count          = var.deployment_node_config.min_count
        max_count          = var.deployment_node_config.max_count
        preemptible        = var.deployment_node_config.preemptible
        service_account    = "${data.google_project.this.number}-compute@developer.gserviceaccount.com"
        node_labels = {
          role = "deployment"
        }
        node_taints = [
          "workload=deployment:NoSchedule"
        ]
      },
      {
        name               = "monitoring-pool"
        image_type         = "ubuntu_containerd"
        machine_type       = var.monitoring_node_config.node_type
        min_count          = var.monitoring_node_config.min_count
        max_count          = var.monitoring_node_config.max_count
        preemptible        = var.monitoring_node_config.preemptible
        service_account    = "${data.google_project.this.number}-compute@developer.gserviceaccount.com"
        node_labels = {
          role = "monitoring"
        }
        node_taints = [
          "workload=monitoring:NoSchedule"
        ]
      },
      {
        name               = "job-pool"
        image_type         = "ubuntu_containerd"
        machine_type       = var.job_node_config.node_type
        min_count          = var.job_node_config.min_count
        max_count          = var.job_node_config.max_count
        preemptible        = var.job_node_config.preemptible
        service_account    = "${data.google_project.this.number}-compute@developer.gserviceaccount.com"
        node_labels = {
          role = "job"
        }
        node_taints = [
          "workload=job:NoSchedule"
        ]
      },
    ]

  node_pools_oauth_scopes    = {
    "${local.cluster_name}-node-pool" = [
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/storage.readwrite",
    ]
  }

  cluster_resource_labels = local.common_tags

  depends_on = [data.google_project.this]
}

terraform {
  backend "gcs" {
  }
}




