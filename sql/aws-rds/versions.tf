terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47.0, <= 5.100.0"
    }

    kubectl = {
      source = "alekc/kubectl"
      version = "2.0.4"
    }

  }
  required_version = ">= 1.0.0"
}