terraform {
  required_providers {
    kubectl = {
      source = "alekc/kubectl"
      version = "2.0.4"
    }
  }
  required_version = ">= 1.0.0"
}
