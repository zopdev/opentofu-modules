terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0, < 4.0"
    }

    kubectl = {
      source = "alekc/kubectl"
      version = "2.0.4"
    }

  }
  required_version = ">= 1.2"
}