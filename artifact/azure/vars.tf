variable "resource_group_name" {
  description = "The Azure Resource Group name in which all resources should be created."
  type        = string
  default     = ""
}

variable "app_region" {
  type = string
  description = "Location where the resources to be created"
  default = "eastus"
}

variable "services" {
  description = "List of services to be deployed within the namespace"
  type        = list(string)
  default     = []
}

variable "sku" {
  description = "The SKU name of the container registry (e.g - Basic, Standard and Premium)"
  type        = string
  default     = "Standard"
}

