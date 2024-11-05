terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.12.0"
      configuration_aliases = [google, google.shared-services]
    }

    kubectl = {
      source = "alekc/kubectl"
      version = "2.0.4"
    }
  }
  required_version = ">= 1.0.0"
#  experiments = [module_variable_optional_attrs]
}