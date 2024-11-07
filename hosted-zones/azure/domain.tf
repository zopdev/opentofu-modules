resource "azurerm_dns_zone" "zones" {
  for_each = var.zones
  name                = each.value.domain
  resource_group_name = var.resource_group_name
}

data "google_dns_managed_zone" "gcp_zone" {
  provider    = google.shared-services
  count = try(var.master_zone != ""? true : false,false) ? 1 :0
  name         = var.master_zone
}

resource "google_dns_record_set" "azure_ns" {
  provider    = google.shared-services
  for_each     = { for k , v in var.zones : k => v if v.add_ns_records }
  name = "${azurerm_dns_zone.zones[each.key].name}."
  type = "NS"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.gcp_zone[0].name
  rrdatas = azurerm_dns_zone.zones[each.key].name_servers
}
