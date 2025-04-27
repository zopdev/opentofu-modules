output "name_servers" {
  value = {
    for k, v in var.zones : k =>
    oci_dns_zone.zones[k].freeform_tags["name_servers"]
  }
}
