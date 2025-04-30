terraform {
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = ">= 4.0.0"
    }

    google = {
      source  = "hashicorp/google"
      version = ">= 6.11.0"
    }
  }

  required_version = ">= 1.0.0"
}
