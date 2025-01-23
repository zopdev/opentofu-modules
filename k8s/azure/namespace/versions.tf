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

    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
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

    grafana = {
      source  = "grafana/grafana"
      version = "1.24.0"
    }

    shell = {
      source  = "scottwinkler/shell"
      version = "1.7.7"
    }

  }

  required_version = ">= 1.0.0"
  # experiments = [module_variable_optional_attrs]
}
