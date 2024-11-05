terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "5.22.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0, < 4.0"
    }
  }
}