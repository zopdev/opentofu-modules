module "nginx" {
  source = "../nginx"

  count = local.prometheus_enable ? (var.public_ingress ? 0 : 1) : 0

  app_name                 = local.cluster_name
  common_tags              = local.common_tags
  app_env                  = var.app_env
  inbound_ip               = local.inbound_ip
  public_app               = var.public_app

  depends_on               = [helm_release.prometheus, module.eks]
}