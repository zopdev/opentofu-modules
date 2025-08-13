terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.51.0"
    }

    kubectl = {
      source = "alekc/kubectl"
      version = "2.0.4"
    }
  }
  required_version = ">= 1.0.0"
#  experiments = [module_variable_optional_attrs]
}