terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.25.0"
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
      version = "1.30.0"
    }
  }
}