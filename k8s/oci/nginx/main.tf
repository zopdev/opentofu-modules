resource "helm_release" "nginx_f5" {
  name      = var.app_name
  chart     = "oci://ghcr.io/nginx/charts/nginx-ingress"
  namespace = "kube-system"
  version   = "2.4.4"

  values = [templatefile("${path.module}/templates/nginx-f5-values.yaml", {
    load_balancer_shape  = var.load_balancer_shape
    subnet_id            = var.lb_subnet_id
    lb_ip              = var.lb_ip
    prometheus_enabled = var.prometheus_enabled
  })]
}
