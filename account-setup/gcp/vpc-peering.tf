resource "google_compute_global_address" "private_ip_address" {
  for_each      = toset(keys(var.vpc_config))
  name          = "${each.key}-sql-proxy-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_config[each.key].self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  for_each      = toset(keys(var.vpc_config))
  provider                = google-beta
  network                 = google_compute_network.vpc_config[each.key].self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address[each.key].name]
}