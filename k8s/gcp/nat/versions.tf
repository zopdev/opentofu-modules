terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.11.0"
    }
  }
  required_version = ">= 1.0.0"
#  experiments = [module_variable_optional_attrs]
}