locals {
  hosted_zone = try(var.accessibility.hosted_zone != null ? var.accessibility.hosted_zone : "", "")
  domain_name = try(var.accessibility.domain_name != null ? var.accessibility.domain_name : "", "")
}

data "google_dns_managed_zone" "zone" {
  count        = local.hosted_zone != "" ? 1 : 0
  project      = var.provider_id
  name         = var.accessibility.hosted_zone
}

resource "google_certificate_manager_dns_authorization" "dns_auth" {
  count        = local.hosted_zone != "" ? 1 : 0
  name        = "${local.cluster_name}-dns-auth"
  description = "The ${local.domain_name} dns auth"
  domain      = local.domain_name
  labels      = local.common_tags
}

resource "google_certificate_manager_certificate" "root_cert" {
  count        = local.hosted_zone != "" ? 1 : 0
  name        = "${local.cluster_name}-dns-certificate"
  description = "The wildcard certificate for gke ${local.domain_name}"
  managed {
    domains = [local.domain_name, "*.${local.domain_name}"]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.dns_auth[0].id
    ]
  }
  labels      = local.common_tags
}

resource "google_certificate_manager_certificate_map" "certificate_map" {
  count        = local.hosted_zone != "" ? 1 : 0
  name        = "${local.cluster_name}-certificate-map"
  description = "The certificate map for gke ${local.domain_name}"
  labels      = local.common_tags
}

resource "google_certificate_manager_certificate_map_entry" "cluster_entry" {
  count        = local.hosted_zone != "" ? 1 : 0
  name         = "${local.cluster_name}-cluster-record-entry"
  description  = "Certificate map entry for the cluster domain"
  map          = google_certificate_manager_certificate_map.certificate_map[0].name
  certificates = [google_certificate_manager_certificate.root_cert[0].id]
  hostname     = local.domain_name
  labels       = local.common_tags
  depends_on = [kubectl_manifest.cluster_wildcard_certificate]
}

resource "google_certificate_manager_certificate_map_entry" "wildcard_entry" {
  count        = local.hosted_zone != "" ? 1 : 0
  name         = "${local.cluster_name}-wildcard-record-entry"
  description  = "Certificate map entry for the cluster wildcard domain"
  map          = google_certificate_manager_certificate_map.certificate_map[0].name
  certificates = [google_certificate_manager_certificate.root_cert[0].id]
  hostname     = "*.${local.domain_name}"
  labels       = local.common_tags
  depends_on = [kubectl_manifest.cluster_wildcard_certificate]
}

resource "google_compute_address" "lb_ip_address" {
  name        = "${local.cluster_name}-https-lb-ip"
  description = "Public IP address of the Global HTTPS load balancer"
  region      = var.app_region
}

# Global load balancer DNS records

# Global load balancer DNS records
resource "google_dns_record_set" "global_load_balancer_sub_domain" {
  count        =  0
  provider     = google.shared-services
  managed_zone = data.google_dns_managed_zone.zone[0].name
  name         = "*.${local.domain_name}."
  type         = "CNAME"
  rrdatas      = ["${local.domain_name}."]
}

