resource "helm_release" "nginx_f5" {
  name      = "${var.app_name}-nginx-f5"
  chart     = "oci://ghcr.io/nginx/charts/nginx-ingress"
  namespace = "kube-system"
  version   = "2.4.3"

  values = [templatefile("${path.module}/templates/nginx-f5-values.yaml", {
    cluster_name = var.app_name
  })]
}
