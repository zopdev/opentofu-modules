variable "app_name" {
  description = "This is the name of the cluster. This name is also used to namespace all the other resources created by this module."
  type        = string
}

variable "app_region" {
  type        = string
  description = "Location where the resources to be created"
  default     = ""
}

variable "namespace" {
  description = "Setup namespace for the services"
  type        = string
  default     = ""
}

variable "accessibility" {
  description = "The list of user access for the account setup"
  type = object({
    domain_name = string
  })
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

variable "common_tags" {
  description = "additional tags for merging with common tags"
  type        = map(string)
  default     = {}
}

variable "standard_tags" {
  description = "standard tags for resources"
  type = object({
    project     = optional(string)
    provisioner = optional(string)
  })
  default = null
}

variable "provider_id" {
  description = "Compartment ID"
  type        = string
  default     = ""
}

variable "user_access" {
  description = "List of users who will have access to clusters"
  type = object({
    admins  = optional(list(string))
    viewers = optional(list(string))
    editors = optional(list(string))
  })
  default = {
    admins  = []
    viewers = []
    editors = []
  }
}

variable "helm_charts" {
  description = "Helm chart installation inputs"
  type = map(object({
    name    = optional(string)
    chart   = optional(string)
    repo    = optional(string)
    version = optional(string)
    values  = optional(any)
    timeout = optional(number)
  }))
  default = {}
}

variable "cert_issuer_config" {
  description = "email to be added as cert-manager issuer"
  type = object({
    env   = optional(string)
    email = string
  })
}

variable "artifact_users" {
  description = "List of users who have access to artifact repository"
  type        = list(string)
  default     = []
}

variable "services" {
  description = "Map of services to be deployed within the namespace"
  type = map(object({
    repo_name              = optional(string)
    oar_name               = optional(string)
    region                 = optional(string)
    account_id             = optional(string)
    db_name                = optional(string)
    redis                  = optional(bool)
    local_redis            = optional(bool)
    custom_secrets         = optional(list(string))
    enable_default_ingress = optional(bool)
    enable_basic_auth      = optional(bool)
    service_deployer       = string
    ingress_list           = optional(list(string))
    badger_db              = optional(bool)
    datastore_configs = optional(object({
      name     = optional(string)
      database = optional(string)
      type     = optional(string)
    }))
    redis_configs = optional(object({
      name = optional(string)
      port = optional(number)
    }))
    helm_configs = optional(object({
      image_pull_secrets = optional(list(string))
      replica_count      = optional(number)
      image              = optional(string)
      cli_service        = optional(bool)
      http_port          = optional(string)
      metrics_port       = optional(string)
      ports              = optional(map(any))
      min_cpu            = optional(string)
      min_memory         = optional(string)
      max_cpu            = optional(string)
      max_memory         = optional(string)
      min_available      = optional(number)
      heartbeat_url      = optional(string)
      env                = optional(map(any))
      env_list = optional(list(object({
        name  = string
        value = string
      })))
      command         = optional(list(string))
      configmaps_list = optional(list(string))
      secrets_list    = optional(list(string))
      hpa = optional(object({
        enable       = optional(bool)
        min_replicas = optional(number)
        max_replicas = optional(number)
        cpu_limit    = optional(string)
        memory_limit = optional(string)
      }))
      readiness_probes = optional(object({
        enable                = optional(bool)
        initial_delay_seconds = optional(number)
        period_seconds        = optional(number)
        timeout_seconds       = optional(number)
        failure_threshold     = optional(number)
      }))
      liveness_probes = optional(object({
        enable                = optional(bool)
        initial_delay_seconds = optional(number)
        period_seconds        = optional(number)
        timeout_seconds       = optional(number)
        failure_threshold     = optional(number)
      }))
      volume_mounts = optional(object({
        configmaps = optional(map(object({
          mount_path = string
          sub_path   = optional(string)
          read_only  = optional(bool)
        })))
        secrets = optional(map(object({
          mount_path = string
          sub_path   = optional(string)
          read_only  = optional(bool)
        })))
        pvc = optional(map(object({
          mount_path = string
          sub_path   = optional(string)
          read_only  = optional(bool)
        })))
      }))
      infra_alerts = optional(object({
        unavailable_replicas_threshold = optional(number)
        pod_restarts_threshold         = optional(number)
        hpa_nearing_max_pod_threshold  = optional(number)
        memory_utilisation_threshold   = optional(number)
        cpu_utilisation_threshold      = optional(number)
      }))
    }))
  }))
  default = {}
}

variable "cron_jobs" {
  description = "Map of cron jobs to be executed within the namespace"
  type = map(object({
    repo_name              = optional(string)
    oar_name               = optional(string)
    gar_project            = optional(string)
    db_name                = optional(string)
    topics                 = optional(list(string))
    subscriptions          = optional(list(string))
    pub_sub                = optional(bool)
    redis                  = optional(bool)
    local_redis            = optional(bool)
    service_account        = optional(string)
    custom_secrets         = optional(list(string))
    ingress_list           = optional(list(string))
    enable_basic_auth      = optional(bool)
    enable_default_ingress = optional(bool)
    badger_db              = optional(bool)
    datastore_configs = optional(object({
      name     = optional(string)
      database = optional(string)
      type     = optional(string)
    }))
    redis_configs = optional(object({
      name = optional(string)
      port = optional(number)
    }))
    helm_configs = optional(object({
      image_pull_secrets = optional(list(string))
      image              = optional(string)
      schedule           = string
      suspend            = optional(bool)
      concurrency_policy = optional(string)
      http_port          = optional(string)
      metrics_port       = optional(string)
      min_cpu            = optional(string)
      min_memory         = optional(string)
      max_cpu            = optional(string)
      max_memory         = optional(string)
      env                = optional(map(any))
      env_list = optional(list(object({
        name  = string
        value = string
      })))
      command         = optional(list(string))
      configmaps_list = optional(list(string))
      secrets_list    = optional(list(string))
      volume_mounts = optional(object({
        configmaps = optional(map(object({
          mount_path = string
          sub_path   = optional(string)
          read_only  = optional(bool)
        })))
        secrets = optional(map(object({
          mount_path = string
          sub_path   = optional(string)
          read_only  = optional(bool)
        })))
      }))
      infra_alerts = optional(object({
        cronjob_failed_threshold = optional(number)
      }))
    }))
  }))
  default = {}
}

variable "sql_list" {
  type = map(object({
    type                  = optional(string)
    admin_user            = optional(string)
    storage               = optional(number)
    storage_scaling       = optional(bool)
    storage_tier          = optional(string)
    read_replica          = optional(bool)
    enable_ssl            = optional(bool)
    deletion_protection   = optional(bool)
    backup_retention_days = optional(number)
    psql_version          = optional(number)
    iops                  = optional(number)
    system_type           = optional(string)
  }))
  default = null
}
