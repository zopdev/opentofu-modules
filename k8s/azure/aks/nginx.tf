module "nginx" {
  source = "../nginx"

  count = local.prometheus_enable ? (var.public_ingress ? 0 : 1) : 0

  app_name                 = local.cluster_name
  node_port                = local.node_port
  node_resource_group      = module.aks.node_resource_group
  lb_ip                    = azurerm_public_ip.app_public_ip.ip_address
  prometheus_enabled       = local.prometheus_enable

  depends_on = [helm_release.prometheus]
}
