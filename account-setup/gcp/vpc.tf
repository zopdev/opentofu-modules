locals {
  private_subnet_map = merge([
  for vpc_name in keys(var.vpc_config) : tomap({
  for subnet in var.vpc_config[vpc_name].private_subnets_cidr : "${vpc_name}-${subnet}" => {
    network = google_compute_network.vpc_config[vpc_name].self_link
    subnet = subnet
    vpc_name = vpc_name
  }
  })
  ]...)
}


resource "google_compute_network" "vpc_config" {
  for_each  = toset(keys(var.vpc_config))
  project   =  var.provider_id
  name      = each.key
  auto_create_subnetworks = false

  depends_on = [google_project_service.dns, google_project_service.compute_project]
}

resource "google_compute_subnetwork" "subnet_config" {
  for_each      = local.private_subnet_map
  project       = var.provider_id
  ip_cidr_range = each.value.subnet
  name          = "${each.value.vpc_name}-private-subnet"
  network       = each.value.network
  region        = var.app_region
}

resource "google_compute_firewall" "vpc_firewall" {
  for_each  = toset(keys(var.vpc_config))
  name               = "${each.key}-firewall"
  network            =  google_compute_network.vpc_config[each.key].self_link

  direction       = "INGRESS"

  allow {
    protocol        = "all"
    ports           = []
  }

  source_ranges     = ["0.0.0.0"]
}


resource "google_compute_router" "router" {
  for_each  = toset(keys(var.vpc_config))
  project = var.provider_id
  name    = "nat-router-${google_compute_network.vpc_config[each.key].name}"
  network = google_compute_network.vpc_config[each.key].name
  region  = var.app_region
}

module "cloud-nat" {
  for_each  = toset(keys(var.vpc_config))
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 5.0"
  project_id                         = var.provider_id
  region                             = var.app_region
  router                             = google_compute_router.router[each.key].name
  name                               = "nat-config-${google_compute_network.vpc_config[each.key].name}"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}