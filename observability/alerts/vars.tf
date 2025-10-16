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

variable "otel" {
  description = "Otel collector configuration"
  type        = object({
    enable = bool
    scrape_interval        = optional(string)
    batch_size             = optional(string)
    timeout                = optional(string)
    spike_limit_percentage = optional(string)
    limit_percentage       = optional(string)
    check_interval         = optional(string)
    queue_size             = optional(string)
    num_consumers          = optional(string)
    initial_interval       = optional(string)
    max_interval           = optional(string)
    max_elapsed_time       = optional(string)
  })
}
