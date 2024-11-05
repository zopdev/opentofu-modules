variable "provider_id" {
  description = "The project ID to host the database in."
  type        = string
  default     = ""
}

variable "app_name" {
  description = "This is the name of the cluster. This name is also used to namespace all the other resources created by this module."
  type        = string
}

variable "app_env" {
  description = "Application deployment environment."
  type        = string
  default     = ""
}

variable "bucket_name" {
  description = "Name of the bucket"
  type = string
}

variable "app_region" {
  description = "The region to host the database in."
  type        = string
  default     = ""
}

variable "vpc" {
  description = "The VPC where the redis instance/cluster will be created."
  type        = string
}

variable "labels" {
  description = "Common Labels on the resources"
  type        = map(string)
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "redis" {
  description = "Inputs to provision Redis instances in the cloud platform"
  type        = object(
    {
      machine_type           = string
      memory_size            = string
      replica_count          = number
      connect_mode           = optional(string)
      redis_version          = optional(string)
    }
  )
  default = {
    machine_type           = "BASIC"
    memory_size            = "1"
    replica_count          = 1
    connect_mode           = "DIRECT_PEERING"
    redis_version          = "REDIS_7_0" 
  }
}

variable "cluster_prefix" {
  description = "prefix for cluster terraform state file"
  type = string
  default = ""
}