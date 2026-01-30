locals {
  reloader_template = templatefile(
    "${path.module}/templates/reloader-values.yaml",
    {}  # no vars
  )
}

resource "helm_release" "reloader" {
  name       = "reloader"
  repository = "https://stakater.github.io/stakater-charts"
  chart      = "reloader"
  version    = "1.0.60"

  values = [
    local.reloader_template
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
  ]
}
