variable "app_name" {
  description = "This is the name for the project. This name is also used to namespace all the other resources created by this module."
  type        = string
}

variable "app_env" {
  description = "Application deployment environment."
  type        = string
  default     = ""
}

variable "app_region" {
  description = "Cloud region to deploy to (e.g. us-east1)"
  type        = string
}

variable "project_id" {
  description = "Project ID"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Cloud DNS host name for the service"
  type        = string
  default     = ""
}

variable "hosted_zone" {
  description = "Hosted zone name for the records"
  type        = string
  default     = ""
}

variable "observability_suffix" {
  description = "To add a suffix to Storage Buckets in Observability Cluster"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Common Labels on the resources"
  type        = map(string)
}

variable "service_account_name_prefix" {
  description = "Prefix to be used for Service Account Names"
  type        = string
}

variable "loki" {
  description = "Loki configuration for observability setup"
  type = object({
    enable = bool
    enable_ingress = optional(bool)
    alerts = optional(object({
      distributor_lines_received = optional(string)
      distributor_bytes_received= optional(number)
      distributor_appended_failures = optional(number)
      request_errors = optional(number)
      panics = optional(number)
      request_latency = optional(number)
      distributor_replica = optional(number)
      ingester_replica  = optional(number)
      querier_replica = optional(number)
      query_frontend_replica = optional(number)
      compactor_replica = optional(number)
    }))
    ingester = optional(object({
      replicas           = optional(number)
      max_memory         = optional(string)
      min_memory         = optional(string)
      max_cpu            = optional(string)
      min_cpu            = optional(string)
      autoscaling        = optional(bool)
      max_replicas       = optional(number)
      min_replicas       = optional(number)
      memory_utilization = optional(string)
      cpu_utilization    = optional(string)
    }))
    distributor = optional(object({
      replicas           = optional(number)
      max_memory         = optional(string)
      min_memory         = optional(string)
      max_cpu            = optional(string)
      min_cpu            = optional(string)
      autoscaling        = optional(bool)
      max_replicas       = optional(number)
      min_replicas       = optional(number)
      memory_utilization = optional(string)
      cpu_utilization    = optional(string)
    }))
    querier = optional(object({
      replicas           = optional(number)
      max_unavailable    = optional(number)
      min_memory         = optional(string)
      max_memory         = optional(string)
      min_cpu            = optional(string)
      max_cpu            = optional(string)
      autoscaling        = optional(bool)
      max_replicas       = optional(number)
      min_replicas       = optional(number)
      memory_utilization = optional(string)
      cpu_utilization    = optional(string)
    }))
    query_frontend = optional(object({
      replicas           = optional(number)
      min_memory         = optional(string)
      max_memory         = optional(string)
      min_cpu            = optional(string)
      max_cpu            = optional(string)
      autoscaling        = optional(bool)
      max_replicas       = optional(number)
      min_replicas       = optional(number)
      memory_utilization = optional(string)
      cpu_utilization    = optional(string)
    }))
  })
}

variable "cortex" {
  description = "Cortex configuration for observability setup"
  type        = object({
    enable = bool
    enable_ingress = optional(bool)
    alerts = optional(object({
      distributor_replica = optional(number)
      ingester_replica  = optional(number)
      querier_replica = optional(number)
      query_frontend_replica = optional(number)
      compactor_replica = optional(number)
    }))
    limits = optional(object({
      ingestion_rate        = optional(number)
      ingestion_burst_size  = optional(number)
      max_series_per_metric = optional(number)
      max_series_per_user   = optional(number)
      max_fetched_chunks_per_query = optional(number)
    }))
    query_range = optional(object({
      memcached_client_timeout = optional(string)
    }))
    compactor = optional(object({
      enable             = optional(bool)
      replicas           = optional(number)
      persistence_volume = optional(object({
        enable = optional(bool)
        size   = optional(string)
      }))
      min_cpu    = optional(string)
      max_cpu    = optional(string)
      min_memory = optional(string)
      max_memory = optional(string)
    }))
    ingester               = optional(object({
      replicas           =  optional(number)
      persistence_volume = optional(object({
        size = optional(string)
      }))
      min_memory         = optional(string)
      max_memory         = optional(string)
      min_cpu            = optional(string)
      max_cpu            = optional(string)
      autoscaling        = optional(bool)
      max_replicas       = optional(number)
      min_replicas       = optional(number)
      memory_utilization = optional(string)
    }))
    querier = optional(object({
      replicas           = optional(number)
      min_memory         = optional(string)
      max_memory         = optional(string)
      min_cpu            = optional(string)
      max_cpu            = optional(string)
      autoscaling        = optional(bool)
      max_replicas       = optional(number)
      min_replicas       = optional(number)
      memory_utilization = optional(string)
      cpu_utilization    = optional(string)
    }))
    query_frontend = optional(object({
      replicas = optional(number)
      enable  = optional(bool)
    }))
    store_gateway = optional(object({
      replication_factor = optional(number)
      replicas           = optional(number)
      persistence_volume = optional(object({
        size = optional(string)
      }))
      min_memory = optional(string)
      min_cpu    = optional(string)
      max_cpu    = optional(string)
      max_memory = optional(string)

    }))
    memcached_frontend = optional(object({
      enable     = optional(bool)
      min_memory = optional(string)
      min_cpu    = optional(string)
      max_cpu    = optional(string)
      max_memory = optional(string)
    }))
    memcached_blocks_index = optional(object({
      enable     = optional(bool)
      min_memory = optional(string)
      min_cpu    = optional(string)
      max_cpu    = optional(string)
      max_memory = optional(string)
    }))
    memcached_blocks = optional(object({
      enable     = optional(bool)
      min_memory = optional(string)
      min_cpu    = optional(string)
      max_cpu    = optional(string)
      max_memory = optional(string)
    }))
    memcached_blocks_metadata = optional(object({
      enable     = optional(bool)
      min_memory = optional(string)
      min_cpu    = optional(string)
      max_cpu    = optional(string)
      max_memory = optional(string)
    }))
    distributor = optional(object({
      replicas           = optional(number)
      min_memory         = optional(string)
      min_cpu            = optional(string)
      max_cpu            = optional(string)
      max_memory         = optional(string)
      autoscaling        = optional(bool)
      min_replicas       = optional(number)
      max_replicas       = optional(number)
      memory_utilization = optional(string)
      cpu_utilization    = optional(string)
    }))
  })
}

variable "tempo" {
  description = "tempo configuration for observability setup"
  type        = object({
    enable   = bool
    enable_ingress = optional(bool)
    alerts = optional(object({
      ingester_bytes_received = optional(number)
      distributor_ingester_appends = optional(number)
      distributor_ingester_append_failures = optional(number)
      ingester_live_traces = optional(number)
      distributor_spans_received = optional(number)
      distributor_bytes_received = optional(number)
      ingester_blocks_flushed = optional(number)
      tempodb_blocklist = optional(number)
      distributor_replica = optional(number)
      ingester_replica  = optional(number)
      querier_replica = optional(number)
      query_frontend_replica = optional(number)
      compactor_replica = optional(number)
    }))
    max_receiver_msg_size = optional(number)
    ingester = optional(object({
      replicas           = optional(number)
      min_memory         = optional(string)
      min_cpu            = optional(string)
      max_cpu            = optional(string)
      max_memory         = optional(string)
      autoscaling        = optional(bool)
      max_replicas       = optional(number)
      min_replicas       = optional(number)
      memory_utilization = optional(string)
      cpu_utilization    = optional(string)
    }))
    distributor = optional(object({
      replicas           = optional(number)
      min_memory         = optional(string)
      min_cpu            = optional(string)
      max_cpu            = optional(string)
      max_memory         = optional(string)
      autoscaling        = optional(bool)
      max_replicas       = optional(number)
      min_replicas       = optional(number)
      memory_utilization = optional(string)
      cpu_utilization    = optional(string)
    }))
    querier = optional(object({
      replicas           = optional(number)
    }))
    query_frontend = optional(object({
      replicas           = optional(number)
    }))
    metrics_generator = optional(object({
      enable                      = optional(bool)
      replicas                    = optional(number)
      service_graphs_max_items    = optional(number)
      service_graphs_wait         = optional(string)
      remote_write_flush_deadline = optional(string)
      remote_write                = optional(list(object({
        host    = optional(string)
        header  = optional(object({
          key   = optional(string)
          value = optional(string)
        }))
      })))
      metrics_ingestion_time_range_slack = optional(string)
    }))
  })
}

variable "mimir" {
  description = "mimir configuration for observability setup"
  type        = object({
    enable    = bool
    enable_ingress = optional(bool)
    alerts = optional(object({
      distributor_replica = optional(number)
      ingester_replica  = optional(number)
      querier_replica = optional(number)
      query_frontend_replica = optional(number)
      compactor_replica = optional(number)
    }))
    limits = optional(object({
      ingestion_rate        = optional(number)
      ingestion_burst_size  = optional(number)
      max_fetched_chunks_per_query = optional(number)
      max_cache_freshness   = optional(number)
      max_outstanding_requests_per_tenant = optional(number)
    }))
    compactor = optional(object({
      replicas           = optional(number)
      persistence_volume = optional(object({
        enable = optional(bool)
        size   = optional(string)
      }))
      min_cpu    = optional(string)
      max_cpu    = optional(string)
      min_memory = optional(string)
      max_memory = optional(string)
    }))
    ingester               = optional(object({
      replicas           =  optional(number)
      persistence_volume = optional(object({
        size = optional(string)
      }))
      min_memory         = optional(string)
      max_memory         = optional(string)
      min_cpu            = optional(string)
      max_cpu            = optional(string)
    }))
    querier = optional(object({
      replicas           = optional(number)
      min_memory         = optional(string)
      max_memory         = optional(string)
      min_cpu            = optional(string)
      max_cpu            = optional(string)
    }))
    query_frontend = optional(object({
      replicas = optional(number)
    }))
    store_gateway = optional(object({
      replication_factor = optional(number)
      replicas           = optional(number)
      persistence_volume = optional(object({
        size = optional(string)
      }))
      min_memory = optional(string)
      min_cpu    = optional(string)
      max_cpu    = optional(string)
      max_memory = optional(string)
    }))
    distributor = optional(object({
      replicas           = optional(number)
      min_memory         = optional(string)
      min_cpu            = optional(string)
      max_cpu            = optional(string)
      max_memory         = optional(string)
    }))
    caches = optional(object({
      chunks = optional(object({
        enabled           = optional(bool)
        replicas          = optional(number)
        max_item_memory   = optional(number)
        connection_limit  = optional(number)
      }))
      index = optional(object({
        enabled           = optional(bool)
        replicas          = optional(number)
        max_item_memory   = optional(number)
        connection_limit  = optional(number)
      }))
      metadata = optional(object({
        enabled           = optional(bool)
        replicas          = optional(number)
        max_item_memory   = optional(number)
        connection_limit  = optional(number)
      }))
    }))

  })
}

variable "openobserve" {
  description = "List of OpenObserve instances to deploy"
  type = list(object({
    enable = bool
    name = string
    replicaCount = optional(number, 2)
    min_cpu = optional(string, "500m")
    max_cpu = optional(string, "1")
    min_memory = optional(string, "512Mi")
    max_memory = optional(string, "1Gi")
    enable_ingress = optional(bool, true)
    env = optional(list(object({
      name = string
      value = string
    })), [])
  }))
  default = []
}

variable "otel" {
  description = "OTel collector configuration"
  type = object({
    enable                 = bool
    version                = optional(string)
    remote_write           = optional(list(object({
      host = optional(string)
      header = optional(object({
        key   = optional(string)
        value = optional(string)
      }))
    })))
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
  default = null
}