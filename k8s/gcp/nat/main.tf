data "google_compute_network" "vpc" {
  name    = var.vpc
}

resource "google_compute_router" "router" {
  project = var.provider_id
  name    = "nat-router-${var.vpc}"
  network = data.google_compute_network.vpc.name
  region  = var.app_region
}

module "cloud-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 5.0"
  project_id                         = var.provider_id
  region                             = var.app_region
  router                             = google_compute_router.router.name
  name                               = "nat-config-${var.vpc}"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

terraform {
  backend "gcs" {
  }
}