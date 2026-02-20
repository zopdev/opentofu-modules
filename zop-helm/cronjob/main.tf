locals {
   # Check if env_list is null or empty
  env_list = var.env_list != null ? var.env_list : []

  # Check if APP_NAME exists in the env_list
  app_name_exists_list = length([for item in local.env_list : item if item.name == "APP_NAME"]) > 0

  # Add APP_NAME to the env_list if it doesn't exist
  env_list_with_app_name = local.app_name_exists_list ? local.env_list : concat(local.env_list, [{
    name  = "APP_NAME"
    value = var.name
  }])

  # Sort env_list by name for deterministic ordering
  env_map = {
    for item in local.env_list_with_app_name :
    item.name => item.value
  }

  updated_env_list = [
    for name in sort(keys(local.env_map)) : {
      name  = name
      value = local.env_map[name]
    }
  ]
}

resource "helm_release" "cron_helm"{
  name        = var.name
  namespace   = var.namespace
  repository  = "https://helm.zop.dev"
  version     = "v0.0.17"
  chart       = "cron-job"
  reuse_values = true
  max_history  = var.max_history

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
    command                         = var.command 
    env                             = jsonencode(var.env)
    envList                         = jsonencode(local.updated_env_list)
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
