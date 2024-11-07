terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0, < 4.0"
    }

    google = {
      source = "hashicorp/google"
      version = "5.12.0"
    }

  }

  required_version = ">= 1.0.0"
  # experiments = [module_variable_optional_attrs]
}
