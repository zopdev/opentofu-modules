variable "app_name" {
    description = "This is the name of the cluster. This name is also used to namespace all the other resources created by this module."
    type        = string
}

variable "app_region" {
  description = "App region of the cluster"
  type        = string
}

variable "host" {
  description = "Domain to be used for kube-management-api"
  type        = string
}

variable "cluster_name" {
  description = "Name of the cluster on which kube-management-api should be deployed"
  type        = string
}

variable "provider_id" {
  description = "Compartment ID"
  type        = string
}

variable "cluster_ca_cert" {
  description = "CA certificate of the OKE Cluster"
  type        = string
  default     = null
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