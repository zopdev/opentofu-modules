resource "helm_release" "nginx_ingress" {
  name       = var.app_name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "kube-system"
  version    = "4.7.0"

  values = [templatefile("${path.module}/templates/ingress-nginx-values.yaml", {
    cluster_name       = var.app_name
    lb_ip              = var.lb_ip
    prometheus_enabled = var.prometheus_enabled
  })
  ]

  set {
    name  = "controller.service.loadBalancerIP"
    value = var.lb_ip
  }
}