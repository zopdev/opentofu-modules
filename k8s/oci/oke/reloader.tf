locals {
  reloader_values = templatefile("${path.module}/templates/reloader-values.yaml", {})
}

resource "helm_release" "reloader" {
  name       = "reloader"
  repository = "https://stakater.github.io/stakater-charts"
  chart      = "reloader"
  version    = "1.0.60"

  values = [
    local.reloader_values
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
  ]
}
