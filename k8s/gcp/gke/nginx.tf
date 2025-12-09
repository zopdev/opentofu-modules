
module "nginx" {
  project = var.provider_id


  source             = "../nginx"
  node_port          = local.node_port
  app_env            = var.app_env
  app_region         = var.app_region
  app_name           = local.cluster_name
  lb_ip              = google_compute_address.lb_ip_address.address
  prometheus_enabled = local.prometheus_enable

  depends_on = [helm_release.prometheus]
}