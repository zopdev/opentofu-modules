data "template_file" "reloader_template" {
  template = file("${path.module}/templates/reloader-values.yaml")
  vars     = {
  }
}

resource "helm_release" "reloader" {
  name       = "reloader"
  repository = "https://stakater.github.io/stakater-charts"
  chart      = "reloader"
  version    = "1.0.60"

  values = [
    data.template_file.reloader_template.rendered
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
  ]
}
