resource "helm_release" "nginx_f5" {
  name      = var.app_name
  chart     = "oci://ghcr.io/nginx/charts/nginx-ingress"
  namespace = "kube-system"
  version   = "2.4.4"

  values = [templatefile("${path.module}/templates/nginx-f5-values.yaml", {
    cluster_name = split("-", var.app_name)[0]
  })]
}
