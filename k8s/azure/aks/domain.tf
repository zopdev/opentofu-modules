locals {
  domain_name = try(var.accessibility.domain_name != null ? var.accessibility.domain_name  : "", "")
}

data "azurerm_dns_zone" "dns_zone" {
  name                  = var.accessibility.domain_name
  resource_group_name   = var.resource_group_name
}

resource "azurerm_public_ip" "app_public_ip" {
  name                = "${local.cluster_name}-publicIP"
  location            = var.app_region
  resource_group_name = module.aks.node_resource_group
  allocation_method   = "Static"
  sku                 = var.publicip_sku
}

resource "azurerm_dns_a_record" "a_record" {
  name                  = "*"
  zone_name             = data.azurerm_dns_zone.dns_zone.name
  resource_group_name   = data.azurerm_dns_zone.dns_zone.resource_group_name
  ttl                   = 60
  records               = [azurerm_public_ip.app_public_ip.ip_address]
}
