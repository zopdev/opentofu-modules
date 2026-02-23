# F5 NGINX Ingress Controller only (same IngressClass name "nginx", no community chart).
# OCI LoadBalancer; optional reserved IP via annotation when lb_ip is set.
resource "helm_release" "nginx_f5" {
  name      = "${var.app_name}-nginx-f5"
  chart     = "oci://ghcr.io/nginx/charts/nginx-ingress"
  namespace = "kube-system"
  version   = "2.4.3"

  values = [templatefile("${path.module}/templates/nginx-f5-values.yaml", {
    cluster_name         = var.app_name
    load_balancer_shape  = var.load_balancer_shape
    subnet_id            = var.lb_subnet_id
    lb_ip                = var.lb_ip
    prometheus_enabled   = var.prometheus_enabled
  })]
}
