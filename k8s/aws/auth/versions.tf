terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47.0, <= 5.100.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }

    kubectl = {
      source = "alekc/kubectl"
      version = "2.0.4"
    }


  }
  required_version = ">= 1.0.0"
  #  experiments = [module_variable_optional_attrs]

}
