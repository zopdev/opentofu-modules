variable "resource_group_name" {
  description = "The Azure Resource Group name in which all resources should be created."
  type        = string
  default     = ""
}

variable "app_name" {
  type        = string
  description = "The name for the AKS resources created in the specified Azure Resource Group."
  default     = null
}

variable "app_env" {
  description = "Application deployment environment."
  type        = string
  default     = ""
}

variable "app_region" {
  type = string
  description = "Location where the resources to be created"
  default     = ""
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
  })
}

variable "public_ingress" {
  description = "Whether ingress is public or not."
  type        = string
  default     = false
}

variable "kubernetes_version" {
  description = "Kubernetes version of the AKS Cluster"
  type        = string
  default     = "1.31.10"
}

variable "user_access" {
  description = "List of users who will have access to clusters"
  type = object({
    app_admins = optional(list(string))
    app_viewers = optional(list(string))
    app_editors = optional(list(string))
  })
  default = {
    app_admins =  []
    app_viewers = []
    app_editors = []
  }
}

variable "grafana_access" {
  description = "List of users who will have access to grafana"
  type = object({
    grafana_admins = optional(list(string))
    grafana_viewers = optional(list(string))
    grafana_editors = optional(list(string))
  })
  default = {
    grafana_admins =  []
    grafana_viewers = []
    grafana_editors = []
  }
}

variable "enable_auto_scaling" {
  type        = bool
  description = "Enable node pool autoscaling"
  default     = true
}

variable "node_config" {
  description = "List of values for the node configuration of kubernetes cluster"
  type        = object({
    node_type       = string
    min_count       = number
    max_count       = number
    required_workload_type = optional(string)
  })
  validation {
    condition = (var.node_config.min_count > 0)
    error_message = "The variable kube_node_count_min must be greater than 0."
  }
  validation {
    condition = (var.node_config.max_count < 30)
    error_message = "The variable kube_node_count_max value must less than 30."
  }
}

variable "app_namespaces" {
  description = "List of envs and respective users who will have access to edit non system resources in this cluster"
  type                 = map(object({
    alert_webhooks     = optional(list(object({
      type             = string
      data             = string
      labels           = optional(map(string))
    })))
  }))
  default = {}
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

variable "cluster_alert_webhooks" {
  description = "details for setting up of different types of alerts."
  type        = list(object({
    type           = string
    data           = string
    labels = optional(map(string))
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

variable "custom_secrets_name_list" {
  description = " list of aws secrets that were manually created by prefixing cluster name and environment "
  type        = map(
    object(
      {
        secrets = list(string)
      }
    )
  )
  default = {}
}

variable "pagerduty_integration_key" {
  description = "Pagerduty Integration key to send data to Pagerduty"
  type = string
  default = ""
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
        username = optional(string)
        password = optional(string)
      })))
    }))
    grafana = optional(object({
      version           = optional(string)
      enable           = bool
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
      }))
      configs = optional(object({
        datasource_list = optional(map(any))
        domains         = optional(list(string))
        enable_sso      = optional(bool)
      }))
    }))
    kubernetes_event_exporter = optional(object({
      enable              = bool
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


variable "domain_name_label" {
  description = "Name of the domain label for Public IP(fqdn)"
  type = string
  default = "sample-domains"
}

variable "publicip_sku" {
  description = "Public IP address SKU type"
  type = string
  default = "Standard"
}

variable "monitoring_type" {
  description = "Whether you want to use basic or rlog for monitoring (e.g basic or rlog)"
  type        = string
  default     = "basic"
}

variable "rlog_host" {
  description = "Rlog Host endpoint to monitor the logs, metrics and traces (if monitoring_type is rlog, must provide this value)"
  type        = string
  default     = ""
}

variable "fluent_bit" {
  description = "Inputs for Fluent Bit configurations"
  type        = object({
    enable   = bool
    loki     = optional(list(object({
      host      = string
      tenant_id = optional(string)
      labels    = string
      port      = optional(number)
      tls       = optional(string)
    })))
    http     = optional(list(object({
      host       = string
      port       = optional(number)
      uri        = optional(string)
      headers     = optional(list(object({
        key   = string
        value = string
      })))
      tls        = optional(string)
      tls_verify = optional(string)
    })))
    splunk  = optional(list(object({
      host       = string
      token      = string
      port       = optional(number)
      tls        = optional(string)
      tls_verify = optional(string)
    })))
    datadog = optional(list(object({
      host       = string
      api_key    = string
      tls        = optional(string)
      compress   = optional(string)
    })))
    new_relic = optional(list(object({
      host       = optional(string)
      api_key    = string
      compress   = optional(string)
    })))
    slack  = optional(list(object({
      webhook    = string
    })))
  })
  default = null
}

variable "provisioner" {
  description = "Provisioner being used to setup Infra"
  type        = string
  default     = "zop-dev"
}

variable "acr_list" {
  description = "list of acr for cluster pull permission"
  type = list(string)
  default = []
}

variable "log_analytics_workspace_enabled" {
  description = "enable azure log analytics"
  type = bool
  default = false
}

variable "cert_issuer_config"{
  description = "email to be added as cert-manager issuer"
  type = object({
    env   = optional(string)
    email = string
  })
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

variable "webhook_alerts_configs" {
  type = list(object({
    name         = string
    url          = string
    send_resolved = optional(bool, true)
    labels       = optional(map(string))
  }))
  default = []
}

variable "dns_zone_list" {
  description = "List of Azure DNS zone names to be used in the ClusterIssuer solvers."
  type        = list(string)
  default     = []
}

variable "vpc" {
  description = "VNet name the apps are going to use. When provided along with subnet, resources will be deployed inside the VNet."
  type        = string
  default     = ""
}

variable "subnet" {
  description = "Subnet name the apps are going to use. Must be provided along with vpc for VNet integration."
  type        = string
  default     = ""
}

variable "service_cidr_third_octet" {
  description = "Third octet for Kubernetes service CIDR calculation (e.g., 240 for 10.1.240.0/20). Should be in high range to avoid conflicts with typical subnet ranges. Default: 240"
  type        = number
  default     = 240
  
  validation {
    condition     = var.service_cidr_third_octet >= 0 && var.service_cidr_third_octet <= 255
    error_message = "service_cidr_third_octet must be between 0 and 255."
  }
}
