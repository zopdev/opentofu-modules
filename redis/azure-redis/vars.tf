variable "resource_group_name" {
  description = "Azure resource group name for redis"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags for azure resources"
  type        = map(any)
}

variable "app_region" {
  type = string
  description = "Location where the resources to be created"
  default = ""
}

variable "vpc" {
  description = "VPC the apps are going to use"
  type        = string
  default     = ""
}

variable "redis" {
  description = "Inputs to provision Redis instances in the cloud platform"
  type        = object(
      {
        sku_name                  = string
        redis_cache_capacity      = number
        redis_cache_family        = string
        redis_enable_non_ssl_port = bool
      })
  default = {
    sku_name                  = "Basic"
    redis_cache_capacity      = 1
    redis_cache_family        = "C"
    redis_enable_non_ssl_port = false
  }
}

variable "namespace" {
  description = "Setup namespace for the services"
  type        = string
  default     = ""
}

variable "app_name" {
    description = "This is the name of the cluster. This name is also used to namespace all the other resources created by this module."
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


variable "app_env" {
  description = "Env of the redis cluster created"
  type = string
  default = ""
}