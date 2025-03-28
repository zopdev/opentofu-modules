variable "name" {
  description = "Name of the service"
  type        = string
}

variable "namespace" {
  description = "Namespace where the resources should be created"
  type        = string
}

variable "image" {
  description = "Image to be used for deployment"
  type        = string
}

variable "image_pull_secrets" {
  description = "Secrets to pull the images from the container registries"
  type        = list(string)
}

variable "http_port" {
  description = "HTTP Port number to be used"
  type        = number
}

variable "metrics_port" {
  description = "Port number to be used for metrics"
  type        = number
}

variable "min_cpu" {
  description = "CPU request for a container, values should be defined only in `millicpu` measure"
  type        = string
}

variable "max_cpu" {
  description = "CPU limit for a container, values should be defined only in `millicpu` measure"
  type        = string
}

variable "min_memory" {
  description = "Memory request for a container, values should be defined only in `Mi` measure"
  type        = string
}

variable "max_memory" {
  description = "Memory limit for a container, values should be defined only in `Mi` measure"
  type        = string
}

variable "env" {
  description = "Environment variables to be defined for a container (legacy map format)"
  type        = map(any)
  default     = {}
}

variable "env_list" {
  description = "Environment variables to be defined for a container (new list format)"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "schedule" {
  description = "The scheduled time for a cron"
  type        = string
}

variable "suspend" {
  description = "Either to suspend execution of Jobs for a CronJob"
  type        = bool
}

variable "concurrency_policy" {
  description = "Concurrency Policy of a CronJob. Accepted values `Forbid`, `Replace` and `Allow`"
  type        = string
}

variable "configmaps_list" {
  description = "List of configmaps from where the env should be injected onto container"
  type        = list(string)
}

variable "app_secrets" {
  description = "List of secrets from where the env should be injected onto container"
  type        = list(string)
}

variable "secrets_list" {
  description = "List of secrets from where the env should be injected onto container"
  type        = list(string)
}

variable "volume_mount_configmaps" {
  description = "List of configmaps that should be mounted onto the container"
  type        = map(object({
    mount_path = string
    sub_path   = optional(string)
    read_only  = optional(bool)
  }))
}

variable "volume_mount_secrets" {
  description = "List of secrets that should be mounted onto the container"
  type        = map(object({
    mount_path = string
    sub_path   = optional(string)
    read_only  = optional(bool)
  }))
}

variable "volume_mount_pvc" {
  description = "List of pvc that should be mounted onto the container"
  type        = map(object({
    mount_path = string
    sub_path   = optional(string)
    read_only  = optional(bool)
  }))
}

variable "db_ssl_enabled" {
  description = "Boolean value whether to mount the DB SSL secrets on the container or not"
  type        = bool
}

variable "infra_alerts" {
  description = "Inputs to override infra alert thresholds"
  type        = object({
    cronjob_failed_threshold = optional(number)
  })
}

variable "pub_sub" {
  type = bool
  default = false
}

variable "service_random_string" {
  type = string
  default = ""
}