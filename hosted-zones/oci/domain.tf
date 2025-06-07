resource "oci_dns_zone" "zones" {
  for_each        = var.zones
  name            = each.value.domain
  compartment_id  = var.provider_id
  zone_type       = "PRIMARY"
}

data "google_dns_managed_zone" "gcp_zone" {
  provider    = google.shared-services
  count       = try(var.master_zone != "" ? true : false, false) ? 1 : 0
  name        = var.master_zone
}

resource "google_dns_record_set" "oci_ns" {
  provider    = google.shared-services
  for_each    = { for k, v in var.zones : k => v if v.add_ns_records }
  name        = "${oci_dns_zone.zones[each.key].name}."
  type        = "NS"
  ttl         = 300

  managed_zone = data.google_dns_managed_zone.gcp_zone[0].name
  rrdatas      = [for ns in oci_dns_zone.zones[each.key].nameservers : ns.hostname]
}

resource "oci_identity_group" "dns_admin_group" {
  for_each       = var.zones
  name           = "${each.key}-group"
  description    = "Group with permissions to manage DNS zone: ${each.value.domain}"
  compartment_id = var.provider_id
}

resource "oci_identity_policy" "dns_management_policy" {
  for_each       = var.zones
  name           = "${each.key}-policy"
  description    = "Allows group to manage DNS resources for zone: ${each.value.domain}"
  compartment_id = var.provider_id

  statements = [
    "Allow group ${oci_identity_group.dns_admin_group[each.key].name} to manage dns-family in compartment id ${var.provider_id}"
  ]
}