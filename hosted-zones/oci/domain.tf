resource "oci_dns_zone" "zones" {
  for_each = var.zones
  name        = each.value.domain
  compartment_id = var.compartment_id
  zone_type   = "PRIMARY"
}

data "google_dns_managed_zone" "gcp_zone" {
  count = try(var.master_zone != "" ? true : false, false) ? 1 : 0
  name  = var.master_zone
}

resource "google_dns_record_set" "oci_ns" {
  provider    = google.shared-services
  for_each    = { for k, v in var.zones : k => v if v.add_ns_records }
  name        = "${oci_dns_zone.zones[each.key].name}."
  type        = "NS"
  ttl         = 300

  managed_zone = data.google_dns_managed_zone.gcp_zone[0].name
  rrdatas      = oci_dns_zone.zones[each.key].freeform_tags["name_servers"]
}

data "oci_dns_zone" "master_zone" {
  count = try(var.master_zone != "" ? true : false, false) ? 1 : 0
  name  = var.master_zone
  compartment_id = var.compartment_id
}

resource "oci_dns_record" "azure_ns" {
  for_each = { for k, v in var.zones : k => v if v.add_ns_records }
  zone_name_or_id = data.oci_dns_zone.master_zone[0].id
  domain          = "${oci_dns_zone.zones[each.key].name}."
  rtype           = "NS"
  ttl             = 300

  records = oci_dns_zone.zones[each.key].freeform_tags["name_servers"]
}
