terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.51.0"
    }

    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

  }
  required_version = ">= 1.0.0"
  #  experiments = [module_variable_optional_attrs]
}