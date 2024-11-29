variable "resource_group_name" {
  description = "The Azure Resource Group name in which all resources should be created."
  type        = string
  default     = ""
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type = string
  default = ""
}

variable "container_name" {
  description = "Name of the container which store tfstate files"
  type = string
  default = ""
}

variable "app_name" {
    description = "This is the name of the cluster. This name is also used to namespace all the other resources created by this module."
    type        = string
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

variable "app_region" {
  type = string
  description = "Location where the resources to be created"
  default = ""
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

variable "cron_jobs" {
  description = "Map of cron jobs to be executed within the namespace"
  type        = map(object({
    repo_name          = optional(string)
    acr_name           = optional(string)
    acr_resource_group = optional(string)
    db_name        = optional(string)
    redis          = optional(bool)
    local_redis    = optional(bool)
    service_account= optional(string)
    custom_secrets = optional(list(string))
    ingress_list   = optional(list(string))
    enable_basic_auth      = optional(bool)
    enable_default_ingress = optional(bool)
    badger_db          = optional(bool)
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
    repo_name          = optional(string)
    acr_name           = optional(string)
    acr_resource_group = optional(string)
    db_name            = optional(string)
    redis              = optional(bool)
    local_redis    = optional(bool)
    enable_default_ingress = optional(bool)
    ingress_list       = optional(list(string))
    custom_secrets     = optional(list(string))
    enable_basic_auth      = optional(bool)
    badger_db          = optional(bool)
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
  }))
  default     = {}
}

variable "cassandra_db" {
  description = "Inputs to provision Cassandra instances"
  type        = object({
    admin_user       = string
    replica_count    = number
    persistence_size = number
    })
  default = null
}

variable "common_tags" {
  description = "additional tags for merging with common tags"
  type        = map(string)
  default     = {}
}

variable "sql_db" {
  description    = "Inputs to provision sql instances"
  type           = object(
    {
      type         = string
      sku_name     = optional(string)
      admin_user   = optional(string)
      enable_ssl   = optional(bool)
      read_replica = optional(bool)
      storage      = optional(number)
      storage_scaling = optional(bool)
      storage_tier    = optional(string)
      iops            = optional(number)
      iops_scaling    = optional(bool)
    })
  default = null
}

variable "custom_namespace_secrets" {
  description = "List of Azure secrets that were manually created by prefixing cluster name, environment and namespace"
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

variable "deploy_env" {
  description = "Deployment environment"
  type        = string
  default     = null
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

variable "vpc" {
  description = "VPC the apps are going to use"
  type        = string
  default     = ""
}

variable "cert_issuer_config"{
  description = "email to be added as cert-manager issuer"
  type = object({
    env   = optional(string)
    email = string
  })
}