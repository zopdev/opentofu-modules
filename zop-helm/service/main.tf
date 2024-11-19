locals {
  # Check if APP_NAME exists in the env map
  app_name_exists = contains(keys(var.env), "APP_NAME")

  # Merge the original env map with the APP_NAME key-value pair if it does not exist
  updated_env = merge(
    var.env,
      local.app_name_exists ? {} : { "APP_NAME" = var.name }
  )
}

resource "helm_release" "service_helm"{
  name        = var.name
  namespace   = var.namespace
  repository  = "https://helm.zop.dev"
  version     = "v0.0.5"
  chart       = "service"
  reuse_values = true

  values = [templatefile("${path.module}/templates/values.yaml", {
    name                            = var.name
    image                           = var.image
    image_pull_secrets              = jsonencode(var.image_pull_secrets)
    replica_count                   = var.replica_count
    cli_service                     = var.cli_service
    http_port                       = var.http_port
    metrics_port                    = var.metrics_port
    ports                           = jsonencode(var.ports)
    min_cpu                         = var.min_cpu
    min_memory                      = var.min_memory
    max_cpu                         = var.max_cpu
    max_memory                      = var.max_memory
    min_available                   = var.min_available
    hpa_enable                      = var.hpa_enable
    hpa_min_replicas                = var.hpa_min_replicas
    hpa_max_replicas                = var.hpa_max_replicas
    hpa_cpu_limit                   = var.hpa_cpu_limit
    hpa_memory_limit                = var.hpa_memory_limit
    heartbeat_url                   = var.heartbeat_url
    env                             = jsonencode(local.updated_env)
    enable_readiness_probe          = var.enable_readiness_probe
    enable_liveness_probe           = var.enable_liveness_probe
    readiness_initial_delay_seconds = var.readiness_initial_delay_seconds
    readiness_period_seconds        = var.readiness_period_seconds
    readiness_timeout_seconds       = var.readiness_timeout_seconds
    readiness_failure_threshold     = var.readiness_failure_threshold
    liveness_initial_delay_seconds  = var.liveness_initial_delay_seconds
    liveness_period_seconds         = var.liveness_period_seconds
    liveness_timeout_seconds        = var.liveness_timeout_seconds
    liveness_failure_threshold      = var.liveness_failure_threshold
    configmaps_list                 = jsonencode(var.configmaps_list)
    app_secrets                     = jsonencode(var.app_secrets)
    secrets_list                    = jsonencode(var.secrets_list)
    volume_mount_configmaps         = jsonencode(var.volume_mount_configmaps)
    volume_mount_secrets            = jsonencode(var.volume_mount_secrets)
    infra_alerts                    = var.infra_alerts
    volume_mount_pvc                = jsonencode(var.volume_mount_pvc)
    db_ssl_enabled                  = var.db_ssl_enabled
    pub_sub                         = var.pub_sub
    service_random_string           = var.service_random_string
  })]

}
