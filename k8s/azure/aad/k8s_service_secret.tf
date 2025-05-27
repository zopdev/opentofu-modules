# Define the Kubernetes provider for Azure AKS
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config" # Adjust to your AKS kubeconfig path
  config_context = "aks_context"    # Adjust to your AKS context
}

# Create a SecretProviderClass for Azure Key Vault
resource "kubernetes_manifest" "secret_provider_class" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "azure-secret-provider"
      namespace = "default" # Adjust to your service namespace
    }
    spec = {
      provider = "azure"
      parameters = {
        keyvaultName = "<your-keyvault-name>" # Replace with your Azure Key Vault name
        objects      = jsonencode([
          {
            objectName = "service-app-secrets" # Name of the secret in Azure Key Vault
            objectType = "secret"
          }
        ])
        tenantId = "<your-tenant-id>" # Replace with your Azure tenant ID
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
