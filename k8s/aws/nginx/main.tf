resource "helm_release" "nginx_ingress" {
  name       = var.app_name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "kube-system"
  version    = "4.5.0"

  values = [templatefile("${path.module}/templates/ingress-nginx-values.yaml", {
    cluster_name = split("-", var.app_name)[0]
  })]
}
