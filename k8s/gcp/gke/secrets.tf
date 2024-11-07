# CSI Driver for secret stores, Helm Chart
resource "helm_release" "csi_driver" {
  chart      = "secrets-store-csi-driver"
  name       = "secrets-store-csi-driver"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  namespace  = "kube-system"
  version    = "1.3.0"

  set {
    name  = "syncSecret.enabled"
    value = "true"
  }
}

locals {
  gcp_secrets_driver_yaml = split("---", file("./templates/gcp-secrets-driver.yaml"))
}

# GCP Secrets driver manifest
resource "kubectl_manifest" "gcp_secrets_driver" {
  for_each  = { for key, id in local.gcp_secrets_driver_yaml : key => id }
  yaml_body = each.value
}
