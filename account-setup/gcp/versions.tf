terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.44.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.48.0, < 5.0"
    }

  }
  required_version = ">= 1.0.0"
}