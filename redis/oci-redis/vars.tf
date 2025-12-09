variable "app_name" {
  description = "This is the name of the cluster. This name is also used to namespace all the other resources created by this module."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "app_region" {
  type        = string
  description = "Location where the resources to be created"
  default     = ""
}

variable "provider_id" {
  description = "OCI Compartment ID"
  type        = string
}

variable "redis" {
  description = "Inputs to provision Redis instances in the cloud platform"
  type = object(
    {
      name          = string
      node_count    = number
      memory_size   = number
      cluster_mode  = optional(string)
      redis_version = optional(string)
    }
  )
  default = {
    name          = ""
    node_count    = 2
    memory_size   = 5
    cluster_mode  = "SHARDED"
    redis_version = "REDIS_7_0"
  }

  validation {
    condition     = var.redis.memory_size >= 2 && var.redis.memory_size <= 500
    error_message = "The memory_size must be between 2 and 500."
  }

  validation {
    condition     = var.redis.node_count >= 1 && var.redis.node_count <= 5
    error_message = "The node_count must be between 1 and 5."
  }
}

variable "shared_services" {
  type = object({
    type            = string
    bucket          = string
    profile         = optional(string)
    location        = optional(string)
    resource_group  = optional(string)
    storage_account = optional(string)
    container       = optional(string)
    cluster_prefix  = optional(string)
  })
}