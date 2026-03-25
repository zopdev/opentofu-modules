resource "helm_release" "nginx_ingress" {
  name       = var.app_name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "kube-system"
  version    = "4.8.2"
  
  values = [templatefile("${path.module}/templates/ingress-nginx-values.yaml", {
    IPV4_ADDRESS        = var.lb_ip
    prometheus_enabled  = var.prometheus_enabled
    load_balancer_shape = var.load_balancer_shape
    subnet_id           = var.lb_subnet_id
  })]
}