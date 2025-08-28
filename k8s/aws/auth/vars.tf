variable "provider_id" {
  description = "profile name"
  type        = string
}

variable "app_name" {
  description = "This is the name for the project. This name is also used to namespace all the other resources created by this module."
  type        = string
  default = ""
}

variable "app_env" {
  description = "Application deployment environment."
  type        = string
  default     = ""
}

variable "masters" {
  description = "List of IAM users who get Admin access to the Cluster"
  type        = list(string)
  default     = []
}

variable "editors" {
  description = "List of IAM users who get Editor access to the Cluster"
  type        = list(string)
  default     = []
}

variable "viewers" {
  description = "List of IAM users who get Viewer access to the Cluster"
  type        = list(string)
  default     = []
}

variable "system_authenticated_admins" {
  description = "List of IAM users who get Authentication access to the Cluster and Admin access on any namespace"
  type        = list(string)
  default     = []
}

variable "system_authenticated_editors" {
  description = "List of IAM users who get Authentication access to the Cluster and Editor access on any namespace"
  type        = list(string)
  default     = []
}

variable "system_authenticated_viewers" {
  description = "List of IAM users who get Authentication access to the Cluster and Viewer access on any namespace"
  type        = list(string)
  default     = []
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

variable "ecr_configs" {
  type =  list(object({
    name = string
    region = string
    account_id = string
  }))
  default = []
}

variable "provisioner" {
  description = "Provisioner being used to setup Infra"
  type        = string
  default     = "zop-dev"
}

variable "karpenter_node_role_name" {
  description = "Name of the Karpenter node IAM role"
  type        = string
  default     = null
}