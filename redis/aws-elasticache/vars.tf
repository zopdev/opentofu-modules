variable "tags" {
  description = "Tags for aws resources"
  type        = map(any)
}

variable "redis" {
  description = "Inputs to provision Redis instances in the cloud platform"
  type        = object({
    name                    = optional(string)
    enable                  = optional(bool)
    node_type               = optional(string)
    replicas_per_node_group = optional(number)
    num_node_groups         = optional(number)
    engine_version          = optional(string)
  })
  default = {
    name                    = ""
    enable                  = true
    node_type               = "cache.m5.large"
    replicas_per_node_group = 1
    num_node_groups         = 2
    engine_version          = "6.2"
  }
}

variable "namespace" {
  description = "Setup namespace for the services"
  type        = string
  default     = ""
}

variable "provider_id" {
  description = "profile name"
  type        = string
}

variable "app_env" {
  description = "Application deployment environment."
  type        = string
  default     = ""
}

variable "app_name" {
  description = "This is the name for the project. This name is also used to namespace all the other resources created by this module."
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