terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.51.0"
    }

    shell = {
      source  = "scottwinkler/shell"
      version = "1.7.7"
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

  }
  required_version = ">= 1.0.0"
  #  experiments = [module_variable_optional_attrs]

}
