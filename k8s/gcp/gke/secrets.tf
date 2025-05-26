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
resource "kubernetes_manifest" "gcp_secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "SecretStore"
    metadata = {
      name      = "gcp-secret-store"
      namespace = "default" # Adjust to your namespace
    }
    spec = {
      provider = {
        gcpsm = {
          projectId = "<your-gcp-project-id>" # Replace with your GCP project ID
          auth = {
            workloadIdentity = {
              serviceAccountRef = {
                name = "<external-secrets-sa>" # Service account with access to Secret Manager
                namespace = "default"          # Adjust namespace if needed
              }
            }
          }
        }
      }
    }
  }
}
