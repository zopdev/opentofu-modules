terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.12.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.48.0, < 5.0"
    }

    kubectl = {
      source = "alekc/kubectl"
      version = "2.0.4"
    }

  }
  required_version = ">= 1.0.0"
}