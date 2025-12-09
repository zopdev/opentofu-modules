# Adds AppDynamics agent optionally provided variables
resource "helm_release" "app_dynamics" {
  count     = var.appd_controller_url == "" || var.appd_controller_url == "" || var.appd_account == "" || var.appd_user == "" || var.appd_password == "" || var.appd_accesskey == "" ? 0 : 1
  chart     = "cluster-agent"
  name      = "cluster-agent"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
  version   = "0.1.18"

  repository = "https://ciscodevnet.github.io/appdynamics-charts"

  values = [
    templatefile("${path.module}/templates/appdynamics.yaml", {
      appd_controller_url = var.appd_controller_url
      appd_account        = var.appd_account
      appd_user           = var.appd_user
      appd_password       = var.appd_password
      appd_accesskey      = var.appd_accesskey
      namespaces          = jsonencode(local.namespaces)
    })
  ]
}