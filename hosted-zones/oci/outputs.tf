output "oci_dns_zone_name_servers" {
  description = "Name servers for each OCI DNS zone"
  value = {
    for k, zone in oci_dns_zone.zones :
    k => [for ns in zone.nameservers : ns.hostname]
  }
}