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

variable "replica_count" {
  description = "Count of Replicas should be created for a deployment"
  type        = number
}

variable "cli_service" {
  description = "If provided service is of type ClI or not"
  type        = bool
}

variable "http_port" {
  description = "HTTP Port number to be used"
  type        = number
}

variable "metrics_port" {
  description = "Port number to be used for metrics"
  type        = number
}

variable "ports" {
  description = "Map of ports that should be configured on container"
  type        = map(any)
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

variable "min_available" {
  description = "PDBs to specify a minimum availability for a particular type of pod for high availability"
  type        = number
}

variable "hpa_enable" {
  description = "Enable HPA for the deployment"
  type        = bool
}

variable "hpa_min_replicas" {
  description = "Minimum number of replicas to be controlled"
  type        = number
}

variable "hpa_max_replicas" {
  description = "Maximum number of replicas to be controlled"
  type        = number
}

variable "hpa_cpu_limit" {
  description = "Scaling target to be set by HPA for CPU utilisation"
  type        = string
}

variable "hpa_memory_limit" {
  description = "Scaling target to be set by HPA for memory utilisation"
  type        = string
}

variable "heartbeat_url" {
  description = "Health Check path for the kubelet to consider the container to be alive and healthy"
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

variable "command" {
  description = "values to be passed as command to the container"
  type = list(string)
  default = [ ]
}

variable "enable_readiness_probe" {
  description = "To enable readiness probe on the container or not"
  type        = bool
}

variable "readiness_initial_delay_seconds" {
  description = "Initial delay seconds that kubelet should wait before performing the first readiness probe"
  type        = number
}

variable "readiness_period_seconds" {
  description = "How often (in seconds) that kubelet should perform readiness probe"
  type        = number
}

variable "readiness_timeout_seconds" {
  description = "Number of seconds after which the readiness probe times out"
  type        = number
}

variable "readiness_failure_threshold" {
  description = "The number of time kubelet should run the probe to consider container is not ready/healthy/live"
  type        = string
}

variable "enable_liveness_probe" {
  description = "To enable liveness probe on the container or not"
  type        = bool
}

variable "liveness_initial_delay_seconds" {
  description = "Initial delay seconds that kubelet should wait before performing the first liveness probe"
  type        = number
}

variable "liveness_period_seconds" {
  description = "How often (in seconds) that kubelet should perform liveness probe"
  type        = number
}

variable "liveness_timeout_seconds" {
  description = "Number of seconds after which the liveness probe times out"
  type        = number
}

variable "liveness_failure_threshold" {
  description = "The number of time kubelet should run the probe to consider container is not ready/healthy/live"
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

variable "volume_mount_pvc_badger" {
  description = "List of pvc that should be mounted onto the container"
  type        = map(object({
    mount_path = string
    sub_path   = optional(string)
    read_only  = optional(bool)
  }))
  default = {}
}

variable "db_ssl_enabled" {
  description = "Boolean value whether to mount the DB SSL secrets on the container or not"
  type        = bool
}


variable "infra_alerts" {
  description = "Inputs to override infra alert thresholds"
  type        = object({
    unavailable_replicas_threshold = optional(number)
    pod_restarts_threshold         = optional(number)
    hpa_nearing_max_pod_threshold  = optional(number)
    memory_utilisation_threshold   = optional(number)
    cpu_utilisation_threshold      = optional(number)
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
