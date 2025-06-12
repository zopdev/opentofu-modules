# Create secondary IP ranges for GKE subnet
resource "google_compute_subnetwork" "gke_subnet" {
  name          = "${local.cluster_name}-subnet"
  ip_cidr_range = data.google_compute_subnetwork.app_subnet.ip_cidr_range
  region        = var.app_region
  network       = data.google_compute_network.vpc.id

  secondary_ip_range {
    range_name    = "pod-range"
    ip_cidr_range = "10.232.0.0/16"  # Larger range for pods
  }

  secondary_ip_range {
    range_name    = "service-range"
    ip_cidr_range = "10.233.0.0/16"  # Larger range for services
  }

  depends_on = [data.google_compute_subnetwork.app_subnet]
} 