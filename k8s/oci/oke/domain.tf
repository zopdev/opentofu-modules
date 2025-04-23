locals {
  domain_name = try(var.accessibility.domain_name != null ? var.accessibility.domain_name : "", "")
}

data "oci_dns_zones" "dns_zone" {
  count          = local.domain_name != "" ? 1 : 0
  name           = var.accessibility.domain_name
  compartment_id = var.provider_id
}

resource "oci_core_public_ip" "lb_public_ip" {
  compartment_id    = var.provider_id
  display_name      = "${local.cluster_name}-public-ip"
  lifetime          = "RESERVED"
    
  lifecycle {
    ignore_changes = all
  }
}

resource "oci_dns_record" "wildcard_record" {
  count           = local.domain_name != "" ? 1 : 0
  zone_name_or_id = data.oci_dns_zones.dns_zone[0].name
  domain          = "*.${local.domain_name}"
  rtype           = "A"
  rdata           = oci_core_public_ip.lb_public_ip.ip_address
  ttl             = 300
}

resource "oci_dns_record" "apex_record" {
  count           = local.domain_name != "" ? 1 : 0
  zone_name_or_id = data.oci_dns_zones.dns_zone[0].name
  domain          = local.domain_name
  rtype           = "A"
  rdata           = oci_core_public_ip.lb_public_ip.ip_address
  ttl             = 300
}