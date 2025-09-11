locals {
  domain_name = try(var.accessibility.domain_name != null ? var.accessibility.domain_name  : "", "")
}

data "azurerm_dns_zone" "dns_zone" {
  count = local.domain_name != "" ? 1 : 0
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
  count = local.domain_name != "" ? 1 : 0
  name                  = "*"
  zone_name             = data.azurerm_dns_zone.dns_zone[0].name
  resource_group_name   = data.azurerm_dns_zone.dns_zone[0].resource_group_name
  ttl                   = 60
  records               = [azurerm_public_ip.app_public_ip.ip_address]
}
