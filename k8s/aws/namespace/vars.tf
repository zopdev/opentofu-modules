variable "app_region" {
  description = "Cloud region to deploy to (e.g. us-east-1)"
  type        = string
}

variable "app_name" {
  description = "This is the name for the project. This name is also used to namespace all the other resources created by this module."
  type        = string
}

variable "public_ingress" {
  description = "Whether ingress is public or not."
  type        = string
  default     = false
}

variable "app_env" {
  description = "Application deployment environment."
  type        = string
  default     = ""
}

variable "namespace" {
  description = "Setup namespace for the services"
  type        = string
  default     = ""
}

variable "cron_jobs" {
  description = "Map of cron jobs to be executed within the namespace"
  type        = map(object({
    repo_name      = optional(string)
    ecr_repo       = optional(string)
    region         = optional(string)
    account_id     = optional(string)
    db_name        = optional(string)
    redis          = optional(bool)
    local_redis    = optional(bool)
    custom_secrets = optional(list(string))
    enable_default_ingress = optional(bool)
    enable_basic_auth      = optional(bool)
    service_deployer = string
    ingress_list = optional(list(string))
    badger_db          = optional(bool)
    datastore_configs = optional(object({
      name = optional(string)
      databse = optional(string)
      type = optional(string)
    }))
    redis_configs = optional(object({
      name = optional(string)
      port = optional(number)
    }))
    helm_configs       = optional(object({
      image_pull_secrets = optional(list(string))
      schedule           = string
      suspend            = optional(bool)
      concurrency_policy = optional(string)
      http_port        = optional(string)
      metrics_port     = optional(string)
      min_cpu          = optional(string)
      min_memory       = optional(string)
      max_cpu          = optional(string)
      max_memory       = optional(string)
      env              = optional(map(any))
      env_list          = optional(list(object({
        name  = string
        value = string
      })))
      configmaps_list  = optional(list(string))
      secrets_list     = optional(list(string))
      volume_mounts  = optional(object({
        configmaps   = optional(map(object({
          mount_path = string
          sub_path   = optional(string)
          read_only  = optional(bool)
        })))
        secrets      = optional(map(object({
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
  default     = {}
}

variable "services" {
  description = "Map of services to be deployed within the namespace"
  type      = map(object({
    repo_name      = optional(string)
    ecr_repo       = optional(string)
    region         = optional(string)
    account_id     = optional(string)
    db_name        = optional(string)
    redis          = optional(bool)
    local_redis    = optional(bool)
    custom_secrets = optional(list(string))
    enable_default_ingress = optional(bool)
    enable_basic_auth      = optional(bool)
    service_deployer = string
    ingress_list = optional(list(string))
    badger_db          = optional(bool)
    datastore_configs = optional(object({
      name = optional(string)
      databse = optional(string)
      type = optional(string)
    }))
    redis_configs = optional(object({
      name = optional(string)
      port = optional(number)
    }))
    helm_configs       = optional(object({
      image_pull_secrets = optional(list(string))
      replica_count    = optional(number)
      cli_service      = optional(bool)
      http_port        = optional(string)
      metrics_port     = optional(string)
      ports            = optional(map(any))
      min_cpu          = optional(string)
      min_memory       = optional(string)
      max_cpu          = optional(string)
      max_memory       = optional(string)
      min_available    = optional(number)
      heartbeat_url    = optional(string)
      env              = optional(map(any))
      env_list          = optional(list(object({
        name  = string
        value = string
      })))
      configmaps_list  = optional(list(string))
      secrets_list     = optional(list(string))
      hpa              = optional(object({
        enable           = optional(bool)
        min_replicas     = optional(number)
        max_replicas     = optional(number)
        cpu_limit        = optional(string)
        memory_limit     = optional(string)
      }))
      readiness_probes        = optional(object({
        enable                = optional(bool)
        initial_delay_seconds = optional(number)
        period_seconds        = optional(number)
        timeout_seconds       = optional(number)
        failure_threshold     = optional(number)
      }))
      liveness_probes         = optional(object({
        enable                = optional(bool)
        initial_delay_seconds = optional(number)
        period_seconds        = optional(number)
        timeout_seconds       = optional(number)
        failure_threshold     = optional(number)
      }))
      volume_mounts  = optional(object({
        configmaps   = optional(map(object({
          mount_path = string
          sub_path   = optional(string)
          read_only  = optional(bool)
        })))
        secrets      = optional(map(object({
          mount_path = string
          sub_path   = optional(string)
          read_only  = optional(bool)
        })))
        pvc      = optional(map(object({
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
  default     = {}
}

variable "user_access" {
  description = "List of users who will have access to clusters"
  type = object({
    admins = optional(list(string))
    viewers = optional(list(string))
    editors = optional(list(string))
  })
  default = {
    admins =  []
    viewers = []
    editors = []
  }
}

#variable "alert_webhooks"  {
#  description = "details for setting up of different types of alerts at namespace level."
#  type  = list(object({
#    type             = string
#    data             = string
#  }))
#  default     = []
#}

variable "accessibility" {
  description = "The list of user access for the account setup"
  type = object({
    domain_name = string
  })
}

variable "sql_db" {
  description = "Map for rds inputs"
  type        = object({
    enable                     = optional(bool)
    admin_user                 = optional(string)
    node_type                  = optional(string)
    disk_size                  = optional(number)
    type                       = optional(string)
    multi_az                   = optional(bool)
    read_replica_multi_az      = optional(bool)
    deletion_protection        = optional(bool)
    read_replica               = optional(bool)
    apply_changes_immediately  = optional(bool)
    rds_max_allocated_storage  = optional(number)
    monitoring_interval        = optional(number)
    log_min_duration_statement = optional(number)
    provisioned_iops           = optional(number)
    engine_version             = optional(string)
    enable_ssl                 = optional(bool)
  })
  default     = null
}

variable "local_redis" {
  description = "Inputs to provision Redis instance within the cluster as a statefulset."
  type        = object(
    {
      enable        = bool
      disk_size     = optional(string)
      storage_class = optional(string)
      max_cpu       = optional(string)
      min_cpu       = optional(string)
      max_memory    = optional(string)
      min_memory    = optional(string)
    }
  )
  default = null
}

variable "cassandra_db" {
  description = "Map for cassandra inputs"
  type        = object(
      {
        admin_user       = string
        replica_count    = number
        persistence_size = number

      }
    )
  default     = null
}

variable "common_tags" {
  description = "additional tags for merging with common tags"
  type        = map(string)
  default     = {}
}

variable "ext_rds_sg_cidr_block" {
  description = " list of cidr blocks which need to be whitelisted on rds sg (currently applicable for qa) "
  type        = list
  default     = ["10.0.0.0/8"]
}

variable "dynamo_db" {
  description = "Map for dynaomo_db inputs"
  type        = map(object({
    hash_key               = string
    range_key              = string
    hash_key_type          = string
    range_key_type         = string
    billing_mode           = string
    read_capacity          = number
    write_capacity         = number
    ttl_enabled            = bool
    ttl_attribute_name     = string
    global_secondary_index = optional(list(object({
      name               = string
      hash_key           = string
      projection_type    = string
      range_key          = optional(string)
      write_capacity     = optional(number)
      read_capacity      = optional(number)
      non_key_attributes = optional(list(string))
    })))
  }))
  default     =  {}
}

variable "custom_namespace_secrets" {
  description = " list of aws secrets that were manually created by prefixing cluster name and environment "
  type        = list(string)
  default     = []
}

variable "ingress_custom_domain" {
  description = "Map for k8 ingress for custom domain."
  type        = map(any)
  default     = {}
  # below is example value
  # ingress_custom_domain  =  {
  #  acme = [{ ---> namespace
  #       service =  "acme-challenge"     ---> service name
  #       domain  =  "*.test1.shgw.link"  ---> custom domain name
  #       name    =  "shgw.link"          ---> this should be unique name
  #     }]
  #   }
}

variable "rds_local_access" {
  description = "whether RDS needs to be allowed to access from local"
  type        = bool
  default     = false
}

variable "kafka" {
  description = "Map for kafka input"
  type        = map(
    object(
      {
        topics = list(string)
      }
    )
  )
  default     = {}
}

variable "provider_id" {
  description = "profile name"
  type        = string
}

variable "github_owner" {
  description = "Name of the Github Organization to create repositories within it."
  type        = string
  default     = ""
}

variable "deploy_env" {
  description = "Deployment environment"
  type        = string
  default     = null
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

variable "provisioner" {
  description = "Provisioner being used to setup Infra"
  type        = string
  default     = "zop-dev"
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

variable "standard_tags" {
  description = "standard tags for resources"
  type        = object ({
    project     = optional(string)
    provisioner = optional(string)
  })
  default = null
}

variable "cert_issuer_config"{
  description = "email to be added as cert-manager issuer"
  type = object({
    env   = optional(string)
    email = string
  })
}

variable "sql_list" {
  description = "Map of RDS inputs for multiple SQL databases"
  type = map(object({
    enable                     = optional(bool)
    admin_user                 = optional(string)
    node_type                  = optional(string)
    disk_size                  = optional(number)
    type                       = optional(string)
    multi_az                   = optional(bool)
    read_replica_multi_az      = optional(bool)
    deletion_protection        = optional(bool)
    read_replica               = optional(bool)
    apply_changes_immediately  = optional(bool)
    rds_max_allocated_storage  = optional(number)
    monitoring_interval        = optional(number)
    log_min_duration_statement = optional(number)
    provisioned_iops           = optional(number)
    engine_version             = optional(string)
    enable_ssl                 = optional(bool)
  }))
  default = {}
}