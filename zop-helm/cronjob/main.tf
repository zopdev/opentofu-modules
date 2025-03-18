locals {
  # Check if APP_NAME exists in the env map
  app_name_exists = contains(keys(var.env), "APP_NAME")

  # Merge the original env map with the APP_NAME key-value pair if it does not exist
  updated_env = merge(
    var.env,
      local.app_name_exists ? {} : { "APP_NAME" = var.name }
  )
}

resource "helm_release" "cron_helm"{
  name        = var.name
  namespace   = var.namespace
  repository  = "https://helm.zop.dev"
  version     = "v0.0.15"
  chart       = "cron-job"
  reuse_values = true


  values = [templatefile("${path.module}/templates/values.yaml", {
    name                            = var.name
    image                           = var.image
    image_pull_secrets              = jsonencode(var.image_pull_secrets)
    schedule                        = var.schedule
    suspend                         = var.suspend
    concurrency_policy              = var.concurrency_policy
    http_port                       = var.http_port
    metrics_port                    = var.metrics_port
    min_cpu                         = var.min_cpu
    min_memory                      = var.min_memory
    max_cpu                         = var.max_cpu
    max_memory                      = var.max_memory
    env                             = jsonencode(local.updated_env)
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

  set {
    name  = "env"
    value = yamlencode(local.updated_env)
  }
}
