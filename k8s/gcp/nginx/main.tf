resource "null_resource" "delete_nginx_ingressclass" {
  triggers = {
    controller = "nginx.org/ingress-controller"
  }

  provisioner "local-exec" {
    command = "kubectl delete ingressclass nginx --ignore-not-found || true"
  }
}

resource "helm_release" "nginx_ingress" {
  name      = var.app_name
  chart     = "oci://ghcr.io/nginx/charts/nginx-ingress"
  namespace = "kube-system"
  version   = "2.4.4"

  values = [templatefile("${path.module}/templates/nginx-f5-values.yaml", {
    lb_ip              = var.lb_ip
    prometheus_enabled = var.prometheus_enabled
  })]

  depends_on = [null_resource.delete_nginx_ingressclass]
}