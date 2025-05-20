module "nginx" {
  source = "../nginx"
  count = var.public_ingress ? 0 : 1 

  oci_compartment_id = var.provider_id
  lb_subnet_id = local.publb_subnet_ids
  app_name                 = local.cluster_name
  lb_ip                    = oci_core_public_ip.lb_public_ip.ip_address
  prometheus_enabled       = false

  depends_on = [ helm_release.prometheus ]
}
