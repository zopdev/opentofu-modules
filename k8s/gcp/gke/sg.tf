resource "google_compute_firewall" "node_group_mgmt" {
  name               = "${local.cluster_name}-ng-firewall"
  network            = data.google_compute_network.vpc.self_link

  direction       = "INGRESS"

  allow {
    protocol        = "tcp"
    ports           = ["22", "443"]
  }

  source_ranges     = ["10.0.0.0/8"]
}

resource "google_compute_firewall" "all_node_mgmt" {
  name               = "${local.cluster_name}-all-ng-firewall"
  network            = data.google_compute_network.vpc.self_link

  direction       = "INGRESS"

  allow {
    protocol        = "tcp"
    ports           = ["22"]
  }

  source_ranges     = ["10.0.0.0/8"]
}