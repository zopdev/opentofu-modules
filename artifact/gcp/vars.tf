variable "registries" {
  description = "List of services to be deployed within the namespace"
  type        = list(string)
  default     = []
}

variable "app_region" {
  description = "Cloud region to deploy to (e.g. us-east1)"
  type = string
  default = ""
}

variable "registry_permissions" {
  description = "List of services to be deployed within the namespace"
  type        = map(object({
    users = list(string)
  }))
  default     = {}
}