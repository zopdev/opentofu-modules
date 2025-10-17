variable "cluster_name" {
  description = "Name of cluster where alerts are being configured"
  type        = string
  default     = ""
}

variable "loki" {
  description = "Loki alerts configuration"
  type        = object({
    enable = bool
    alerts = optional(object({
      distributor_lines_received    = optional(string)
      distributor_bytes_received    = optional(number)
      distributor_appended_failures = optional(number)
      request_errors                = optional(number)
      panics                        = optional(number)
      request_latency               = optional(number)
      distributor_replica           = optional(number)
      ingester_replica              = optional(number)
      querier_replica               = optional(number)
      query_frontend_replica        = optional(number)
      compactor_replica             = optional(number)
    }))
  })
  default = null
}

variable "tempo" {
  description = "Tempo alerts configuration"
  type        = object({
    enable = bool
    alerts = optional(object({
      ingester_bytes_received              = optional(number)
      distributor_ingester_appends         = optional(number)
      distributor_ingester_append_failures = optional(number)
      ingester_live_traces                 = optional(number)
      distributor_spans_received           = optional(number)
      distributor_bytes_received           = optional(number)
      ingester_blocks_flushed              = optional(number)
      tempodb_blocklist                    = optional(number)
      distributor_replica                  = optional(number)
      ingester_replica                     = optional(number)
      querier_replica                      = optional(number)
      query_frontend_replica               = optional(number)
      compactor_replica                    = optional(number)
    }))
  })
  default = null
}

variable "cortex" {
  description = "Cortex alerts configuration"
  type        = object({
    enable         = bool
    enable_ingress = optional(bool)
    alerts         = optional(object({
      distributor_replica    = optional(number)
      ingester_replica       = optional(number)
      querier_replica        = optional(number)
      query_frontend_replica = optional(number)
      compactor_replica      = optional(number)
    }))
  })
  default = null
}

variable "mimir" {
  description = "Mimir alerts configuration"
  type        = object({
    enable         = bool
    enable_ingress = optional(bool)
    alerts         = optional(object({
      distributor_replica    = optional(number)
      ingester_replica       = optional(number)
      querier_replica        = optional(number)
      query_frontend_replica = optional(number)
      compactor_replica      = optional(number)
    }))
  })
  default = null
}

variable "cluster_alert_thresholds" {
    description = "Cluster alerts threshold configuration."
    type = object({
        cpu_utilisation = optional(number)
        cpu_underutilisation = optional(number)
        node_count = optional(number)
        memory_utilisation = optional(number)
        memory_underutilisation = optional(number)
        pod_count = optional(number)
        nginx_5xx_percentage_threshold = optional(number)
        disk_utilization = optional(number)
        cortex_disk_utilization_threshold = optional(number)
        prometheus_disk_utilization_threshold = optional(number)
    })
    default =  {
        cpu_utilisation = 80
        cpu_underutilisation = 20
        node_count = 80
        memory_utilisation = 80
        memory_underutilisation = 20
        pod_count = 80
        nginx_5xx_percentage_threshold = 5
        disk_utilization = 20
        cortex_disk_utilization_threshold = 80
        prometheus_disk_utilization_threshold = 80
    }
}

variable "monitoring_node_config" {
    description = "List of values for the node configuration of kubernetes cluster"
    type        = object({
        enable_monitoring_node_pool = optional(bool)
        node_type       = optional(string)
        min_count       = optional(number)
        max_count       = optional(number)
        availability_zones = optional(list(string))
    })
    default = null
}