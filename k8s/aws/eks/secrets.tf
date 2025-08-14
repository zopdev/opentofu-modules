# CSI Driver for secret stores, Helm Chart
resource "helm_release" "csi_driver" {
  chart      = "secrets-store-csi-driver"
  name       = "secrets-store-csi-driver"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  namespace  = "kube-system"
  version    = "0.1.0"

  set {
    name  = "syncSecret.enabled"
    value = "true"
  }
  set {
    name  = "enableSecretRotation"
    value = "true"       # enable auto-rotation feature
  }

  depends_on = [null_resource.wait_for_cluster]
}

locals {
  aws_secrets_driver_yaml = split("---", file("./templates/aws-secrets-driver.yaml"))
}

# AWS Secrets driver manifest
resource "kubectl_manifest" "aws_secrets_driver" {
  for_each  = { for key, id in local.aws_secrets_driver_yaml : key => id }
  yaml_body = each.value
  depends_on = [module.eks]
}
