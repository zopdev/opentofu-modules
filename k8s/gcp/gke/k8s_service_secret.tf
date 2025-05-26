# Define the Kubernetes provider
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config" # Adjust to your GKE kubeconfig path
  config_context = "gke_context"    # Adjust to your GKE context (e.g., gke_<project>_<region>_<cluster>)
}

# Create a Kubernetes secret
resource "kubernetes_secret_v1" "service_secret" {
  metadata {
    name      = "service-app-secret"
    namespace = "default" # Adjust to the namespace used by your GKE service
  }

  data = var.service_secrets

  # Ensure the secret is replaced on update to trigger recreation
  lifecycle {
    create_before_destroy = true
  }
}

# Define an ExternalSecret to sync secrets from Google Cloud Secret Manager
resource "kubernetes_manifest" "external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "service-app-external-secret"
      namespace = "default" # Adjust to the namespace used by your GKE service
    }
    spec = {
      refreshInterval = "1h" # Refresh secret every hour
      secretStoreRef = {
        name = "gcp-secret-store" # Reference to your SecretStore for GCP
        kind = "SecretStore"
      }
      target = {
        name           = kubernetes_secret_v1.service_secret.metadata[0].name
        creationPolicy = "Owner" # Create and manage the Kubernetes secret
      }
      data = [
        for key, value in var.service_secrets : {
          secretKey = key
          remoteRef = {
            key = "service-app-secrets" # Name of the secret in Google Cloud Secret Manager
            property = key
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_secret_v1.service_secret]
}

# Output the secret name for reference
output "secret_name" {
  value = kubernetes_secret_v1.service_secret.metadata[0].name
}
