output "name_servers" {
  value = {
    for k, v in var.zones : k =>
    azurerm_dns_zone.zones[k].name_servers
  }
}