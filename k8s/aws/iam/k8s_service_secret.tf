# Define the Kubernetes provider for AWS EKS
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config" # Adjust to your EKS kubeconfig path
  config_context = "eks_context"    # Adjust to your EKS context (e.g., <cluster-name>)
}

# Create a SecretProviderClass for AWS Secrets Manager
resource "kubernetes_manifest" "secret_provider_class" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "aws-secret-provider"
      namespace = "default" # Adjust to your service namespace
    }
    spec = {
      provider = "aws"
      parameters = {
        objects = jsonencode([
          {
            objectName = "service-app-secrets" # Name of the secret in AWS Secrets Manager
            objectType = "secretsmanager"
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
