#resource "google_compute_firewall" "allow_http_public_ingress" {
#  name        = "allow-${var.app_env}-${var.app_name}-ingress"
#  network     = var.vpc
#  description = "Allow http inbound traffic"
#
#  direction   = "INGRESS"
#
#  allow {
#    protocol = "tcp"
#    ports    = ["80"]
#  }
#  source_ranges = ["0.0.0.0/0"]
#}
#
#resource "google_compute_firewall" "allow_http_public_egress" {
#  name        = "allow-${var.app_env}-${var.app_name}-egress"
#  network     = var.vpc
#
#  direction   = "EGRESS"
#
#  allow {
#    protocol = "all"
#  }
#  source_ranges = ["0.0.0.0/0"]
#}




