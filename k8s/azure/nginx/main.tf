
# Deletes the community IngressClass "nginx" (spec.controller is immutable, cannot be patched).
# Trigger is static so this runs exactly once during migration and never again.
resource "null_resource" "delete_nginx_ingressclass" {
  triggers = {
    controller = "nginx.org/ingress-controller"
  }

  provisioner "local-exec" {
    command = "kubectl delete ingressclass nginx --ignore-not-found || true"
  }
}

resource "helm_release" "nginx_ingress" {
  name             = var.app_name
  repository       = "https://helm.nginx.com/stable"
  chart            = "nginx-ingress"
  namespace        = "kube-system"
  version          = "2.4.4"

  values = [templatefile("${path.module}/templates/nginx-f5-values.yaml", {
    IPV4_ADDRESS       = var.lb_ip
    RESOURCE_GROUP     = var.node_resource_group
    prometheus_enabled = var.prometheus_enabled
  })]

  depends_on = [null_resource.delete_nginx_ingressclass]
}