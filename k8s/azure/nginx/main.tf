
resource "helm_release" "nginx_ingress" {
  name       = var.app_name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "kube-system"
  version    = "4.8.2"

  values = [templatefile("${path.module}/templates/ingress-nginx-values.yaml", {
    IPV4_ADDRESS          = var.lb_ip
    cluster_name          = split("-", var.app_name)[0]
    RESOURCE_GROUP        = var.node_resource_group
    prometheus_enabled = var.prometheus_enabled
  })]
}