variable "provider_id" {
  description = "Compartment ID"
  type        = string
  default     = ""
}

variable "user_access" {
    description = "List of users who will have access to clusters"
    type = object({
        app_admins = optional(list(string))
        app_viewers = optional(list(string))
        app_editors = optional(list(string))
    })
    default = {
        app_admins  = []
        app_viewers = []
        app_editors = []
    }
}

variable "app_region" {
  description = "Cloud region to deploy to (e.g. us-east-1)"
  type        = string
}

variable "app_name" {
  description = "This is the name for the project. This name is also used to namespace all the other resources created by this module."
  type        = string
}

variable "app_env" {
  description = "Application deployment environment."
  type        = string
  default     = ""
}

variable "node_config" {
  description = "List of values for the node configuration of kubernetes cluster"
  type        = object({
    node_type               = string
    ocpus                   = number
    size                    = number
    memory                  = number
    boot_volume_size        = number
  })
}

variable "common_tags" {
  description = "additional tags for merging with common tags"
  type        = map(string)
  default     = {}
}

variable "accessibility" {
  description = "The list of user access for the account setup"
  type = object({
    domain_name = string
    user_id     = string
    fingerprint = string
  })
}

variable "cert_issuer_config"{
  description = "email to be added as cert-manager issuer"
  type = object({
    env   = optional(string)
    email = string
  })
}

variable "private_key_path" {
  description = "Path for the private key"
  type = string
}

variable "public_ingress" {
  description = "Whether ingress is public or not."
  type        = string
  default     = false
}

variable "observability_config" {
  description = "All the configuration related to observability(e.g prometheus, grafana, loki, tempo and cortex)"
  type        = object({
    suffix     = optional(string)
    prometheus = optional(object({
      version      = optional(string)
      enable      = bool
      persistence  = optional(object({
        disk_size          = optional(string)
        retention_size     = optional(string)
        retention_duration = optional(string)
      }))
      remote_write = optional(list(object({
        host    = optional(string)
        header  = optional(object({
          key   = optional(string)
          value = optional(string)
        }))
      })))
    }))
    grafana = optional(object({
      version           = optional(string)
      enable            = bool
      url               = optional(string)
      min_replica       = optional(number)
      max_replica       = optional(number)
      request_memory    = optional(string)
      request_cpu       = optional(string)
      dashboard  = optional(object({
        limit_memory   = optional(string)
        limit_cpu      = optional(string)
        request_memory = optional(string)
        request_cpu    = optional(string)
      }))
      datasource = optional(object({
        limit_memory   = optional(string)
        limit_cpu      = optional(string)
        request_memory = optional(string)
        request_cpu    = optional(string)
      }))
      persistence = optional(object({
        type       = optional(string)
        disk_size  = optional(string)
        deletion_protection = optional(string)
      }))
      configs = optional(object({
        datasource_list = optional(map(any))
        domains         = optional(list(string))
        enable_sso      = optional(bool)
      }))
    }))
    kubernetes_event_exporter = optional(object({
      enable               = bool
      log_level            = optional(string)
      max_event_age_second = optional(string)
      loki_receivers  = optional(list(object({
        name   = string
        url    = string
        header = optional(object({
          key   = string
          value = string
        }))
        cluster_id = optional(string)
      })))
      webhook_receivers  = optional(list(object({
        name   = string
        type   = string
        url    = string
        header = optional(object({
          key   = string
          value = string
        }))
      })))
      resource = optional(object({
        limit_cpu      = optional(string)
        limit_memory   = optional(string)
        request_cpu    = optional(string)
        request_memory = optional(string)
      }))
    }))
    loki = optional(object({
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
    }))
    cortex = optional(object({
      enable = bool
      enable_ingress = optional(bool)
      limits = optional(object({
        ingestion_rate        = optional(number)
        ingestion_burst_size  = optional(number)
        max_series_per_metric = optional(number)
        max_series_per_user = optional(number)
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
    }))
    mimir = optional(object({
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
        ingestion_rate                      = optional(number)
        ingestion_burst_size                = optional(number)
        max_fetched_chunks_per_query        = optional(number)
        max_cache_freshness                 = optional(string)
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
    }))
    tempo = optional(object({
      enable = bool
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
    }))
  })
  default = null
}

variable "moogsoft_endpoint_api_key" {
  description = "Moogsoft API key to configure your third-party system to send data to Moogsoft."
  type        = string
  default     = ""
}

variable "moogsoft_username" {
  description = "Username for moogsoft authentication"
  type        = string
  default     = ""
}

variable "pagerduty_integration_key" {
  description = "Pagerduty Integration key to send data to Pagerduty"
  type        = string
  default     = ""
}

variable "cluster_alert_webhooks" {
    description = "Details for setting up of different types of alerts."
    type        = list(object({
        type             = string
        data             = string
        labels           = optional(map(string))
    }))
    default     =  []

    # example variable
    # cluster_alert_webhooks = [
    #         {
    #           type = "teams",  ---> teams, moogsoft etc
    #           data = "https://zop.webhook.office.com/webhookb2/a22c241c-63f9-498c-b688-ac26b18d4b65@1113e38c-6dd4-428c-811d-24932bc2d5de/IncomingWebhook/c788d456400a4b399b4f191111da8c3fb/ea9e1aa2-6b1f-41e-8afe-fd5539f2bb8b"
    #          },
    #           {
    #           type = "moogsoft",  ---> teams, moogsoft etc
    #           data = "https://zop.moogsoft.qa/prometheus"
    #          }
    #
    #     ]
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

variable "app_namespaces" {
    description = "Details for setting up of different types of alerts at namespace level."
    type                 = map(object({
        alert_webhooks     = optional(list(object({
            type             = string
            data             = string
            labels           = optional(map(string))
        })))
    }))
    default = {}
}

variable "slack_alerts_configs" {
    type = list(object({
        channel = string
        name    = string
        url     = string
        labels  = optional(map(string))
    }))
    default = []
}