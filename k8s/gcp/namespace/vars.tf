variable "app_name" {
  description = "This is the name of the cluster. This name is also used to namespace all the other resources created by this module."
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

variable "provider_id" {
  description = "ID of the GCP project"
  type        = string
  default     = ""
}

variable "vpc" {
  description = "VPC the apps are going to use"
  type        = string
  default     = ""
}

variable "subnet" {
  description = "Subnets IDs the apps are going to use"
  type        = string
  default     = ""
}

variable "cluster_key" {
  description = "Path for terraform state file of cluster"
  type        = string
  default     = ""
}

variable "namespace" {
  description = "Namespace of the Services to be deployed"
  type        = string
  default     = ""
}

variable "services" {
  description = "Map of services to be deployed within the namespace"
  type        = map(object({
    repo_name      = optional(string)
    gar_name       = optional(string)
    gar_project    = optional(string)
    nginx_rewrite  = optional(bool)
    db_name        = optional(string)
    pub_sub        = optional(bool)
    topics         = optional(list(string))
    subscriptions  = optional(list(string))
    redis          = optional(bool)
    local_redis    = optional(bool)
    service_account= optional(string)
    custom_secrets = optional(list(string))
    ingress_list   = optional(list(string))
    enable_basic_auth      = optional(bool)
    enable_default_ingress = optional(bool)
    badger_db          = optional(bool)
    datastore_configs = optional(object({
      name = optional(string)
      databse = optional(string)
    }))
    redis_configs = optional(object({
      name = optional(string)
      port = optional(number)
    }))
    helm_configs       = optional(object({
      image_pull_secrets = optional(list(string))
      image              = optional(string)
      replica_count    = optional(number)
      cli_service      = optional(bool)
      http_port        = optional(string)
      metrics_port     = optional(string)
      min_cpu          = optional(string)
      min_memory       = optional(string)
      max_cpu          = optional(string)
      max_memory       = optional(string)
      min_available    = optional(number)
      heartbeat_url    = optional(string)
      ports            = optional(map(any))
      env              = optional(map(any))
      env_list         = optional(list(object({
        name  = string
        value = string
      })))
      command = optional(list(string))
      configmaps_list  = optional(list(string))
      secrets_list     = optional(list(string))
      hpa              = optional(object({
        enable           = optional(bool)
        min_replicas     = optional(number)
        max_replicas     = optional(number)
        cpu_limit        = optional(number)
        memory_limit     = optional(number)
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
    ingress_with_secret = optional(list(object({
      host         = string
      cloud_secret = object({
        tls_crt_key = string
        tls_key_key = string
      })
    })), [])
  }))
  default     = {}
}

variable "cron_jobs" {
  description = "Map of cron jobs to be executed within the namespace"
  type        = map(object({
    repo_name      = optional(string)
    gar_name       = optional(string)
    gar_project    = optional(string)
    db_name        = optional(string)
    topics         = optional(list(string))
    subscriptions  = optional(list(string))
    pub_sub        = optional(bool)
    redis          = optional(bool)
    local_redis    = optional(bool)
    service_account= optional(string)
    custom_secrets = optional(list(string))
    ingress_list   = optional(list(string))
    enable_basic_auth      = optional(bool)
    enable_default_ingress = optional(bool)
    badger_db          = optional(bool)
    datastore_configs = optional(object({
      name = optional(string)
      databse = optional(string)
    }))
    redis_configs = optional(object({
      name = optional(string)
      port = optional(number)
    }))
    helm_configs       = optional(object({
      image_pull_secrets = optional(list(string))
      image              = optional(string)
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
      env_list         = optional(list(object({
        name  = string
        value = string
      })))
      command = optional(list(string))
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

variable "user_access" {
  description = "List of users who will have access to clusters"
  type = object({
    admins = optional(list(string))
    viewers = optional(list(string))
    editors = optional(list(string))
  })
  default = {
    admins  = []
    viewers = []
    editors = []
  }
}

variable "artifact_users" {
  description = "List of users who have access to artifact repository"
  type        = list(string)
  default     = []
}

variable "sql_db" {
  description = "Inputs to provision SQL instance"
  type        = object(
    {
      enable                     = optional(bool)
      machine_type               = optional(string)
      disk_size                  = optional(number)
      type                       = optional(string)
      availability_type          = optional(string)
      deletion_protection        = optional(bool)
      read_replica               = optional(bool)
      activation_policy          = optional(string)
      db_collation               = optional(string)
      enable_ssl                 = optional(bool)
      sql_version                = optional(string)
    }
  )
  default = null
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
  description = "Inputs to provision Cassandra instances"
  type        = object(
    {
      admin_user       = string
      replica_count    = number
      persistence_size = number

    }
  )

  default = null
}

variable "custom_namespace_secrets" {
  description = "List of GCP secrets that were manually created by prefixing cluster name, environment and namespace"
  type        = list(string)
  default     = []
}

variable "accessibility" {
  description = "The list of user access for the account setup"
  type = object({
    domain_name = optional(string)
    hosted_zone = optional(string)
  })
}

variable "ext_rds_sg_cidr_block" {
  description = " list of cidr blocks which need to be whitelisted on rds sg (currently applicable for qa) "
  type        = list
  default     = ["10.0.0.0/8"]
}

variable "standard_tags" {
  description = "standard tags for resources"
  type        = object ({
    project     = optional(string)
    provisioner = optional(string)
  })
  default = null
}

variable "common_tags" {
  description = "additional tags for merging with common tags"
  type        = map(string)
  default     = {}
}

variable "artifact_registry_location" {
  description = "required location of the artifact"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "name of the bucket"
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

variable "cluster_prefix" {
  description = "prefix for cluster terraform state file"
  type = string
  default = ""
}

variable "provisioner" {
  description = "Provisioner being used to setup Infra"
  type        = string
  default     = "zop-dev"
}

variable "pub_sub" {
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

variable "sql_list" {
  type = map(object({
    type                    = optional(string)
    sql_version             = optional(string)
    machine_type            = optional(string)
    enable_ssl              = optional(string)
    availability_type       = optional(string)
    db_collation            = optional(string)
    activation_policy       = optional(string)
    deletion_protection     = optional(string)
    read_replica            = optional(string)
    disk_autoresize         = optional(string)
    disk_size               = optional(string)
  }))
  default = null
}