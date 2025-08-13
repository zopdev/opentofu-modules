terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "5.22.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47.0, <= 5.100.0"
    }
  }
}