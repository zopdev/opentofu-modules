# Define the Kubernetes provider for OCI OKE
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config" # Adjust to your OKE kubeconfig path
  config_context = "oke_context"    # Adjust to your OKE context (e.g., cluster_<region>_<cluster-name>)
}

# Create a SecretProviderClass for OCI Vault
resource "kubernetes_manifest" "secret_provider_class" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "oci-secret-provider"
      namespace = "default" # Adjust to your service namespace
    }
    spec = {
      provider = "oci"
      parameters = {
        vault = "<your-vault-ocid>" # Replace with your OCI Vault OCID
        secrets = jsonencode([
          {
            secretId = "<your-secret-ocid>" # Replace with the OCID of service-app-secrets
          }
        ])
      }
      secretObjects = [
        {
          secretName = "service-app-secret" # Name of the Kubernetes secret
          type       = "Opaque"
          data = [
            for key in keys(var.service_secrets) : {
              key        = key
              objectName = key
            }
          ]
        }
      ]
    }
  }
}

# Create a Kubernetes secret (optional, as SecretProviderClass can manage it)
resource "kubernetes_secret_v1" "service_secret" {
  metadata {
    name      = "service-app-secret"
    namespace = "default" # Adjust to your service namespace
  }

  data = var.service_secrets

  # Ensure secret is replaced on update
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [kubernetes_manifest.secret_provider_class]
}

# Output the secret name
output "secret_name" {
  value = kubernetes_secret_v1.service_secret.metadata[0].name
}
