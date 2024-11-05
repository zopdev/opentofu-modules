terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.12.0"
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
    github = {
      source = "integrations/github"
      version = "5.28.0"
    }

  }

  required_version = ">= 1.0.0"
#  experiments = [module_variable_optional_attrs]
}