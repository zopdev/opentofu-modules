variable "resource_group_name" {
  description = "Resource group where the resources exists"
  type        = string
}

variable "cluster_name" {
  description = "Name of the cluster on which kops-kube should be deployed"
  type        = string
}

variable "app_region" {
  description = "App region of the cluster"
  type        = string
}

variable "host" {
  description = "Domain to be used for kops-kube"
  type        = string
}

variable "shared_services" {
  type = object({
    type     = string
    bucket   = string
    profile  = optional(string)
    location = optional(string)
    resource_group = optional(string)
    storage_account = optional(string)
    container = optional(string)
    cluster_prefix = optional(string)
  })
}