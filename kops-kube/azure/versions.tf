terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0, < 4.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }

    google = {
      source = "hashicorp/google"
      version = "5.44.0"
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
      version = ">= 4.48.0, < 5.0"
    }
  }

  required_version = ">= 1.0.0"
}