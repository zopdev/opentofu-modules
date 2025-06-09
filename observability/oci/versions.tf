terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.25.0"
    }

    kubectl = {
      source = "alekc/kubectl"
      version = "2.0.4"
    }
  }
  required_version = ">= 1.0.0"
}