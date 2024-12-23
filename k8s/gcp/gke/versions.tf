terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.11.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.14.0"
    }

    kubectl = {
      source = "alekc/kubectl"
      version = "2.0.4"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.48.0, < 5.13"
    }

    grafana = {
      source  = "grafana/grafana"
      version = "1.24.0"
    }
  }
  required_version = ">= 1.0.0"
#  experiments = [module_variable_optional_attrs]
}