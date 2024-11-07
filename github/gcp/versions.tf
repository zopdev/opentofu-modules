terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "5.22.0"
    }
    google      = {
      source  = "hashicorp/google"
      version = "5.12.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.48.0, < 5.0"
    }
  }
}