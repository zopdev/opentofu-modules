output "name_servers" {
  value = {
    for k,v in var.zones : k =>
google_dns_managed_zone.dns_zone[k].name_servers
  }
}