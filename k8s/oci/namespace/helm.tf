resource "helm_release" "helm_chart" {
  for_each = var.helm_charts
  repository = each.value.repo
  chart      = each.value.chart
  name       = each.value.name
  version    = each.value.version
  namespace  = kubernetes_namespace.app_environments.metadata[0].name
  timeout    = each.value.timeout
  values     = [yamlencode(each.value.values)]
}
