locals {

  cron_image_file_content = data.external.cron_file_content.result != null ? data.external.cron_file_content.result : {}

  cron_api_image_map = { # Create a map to store API names and image versions
    for k, v in local.cron_image_file_content : k => v
  }

  cron_existing_images = tomap({
    for k,v in var.cron_jobs : k => local.cron_api_image_map[k] if contains(keys(local.cron_api_image_map), k )
  })

  cron_new_images = tomap({
    for k,v in var.cron_jobs : k => "zopdev/sample-go-api:latest" if (! contains(keys(local.cron_api_image_map), k ))
  })

  cron_all_images = merge(local.cron_existing_images, local.cron_new_images)

}

resource "null_resource" "run_cron_script" {
  # Use triggers to force the execution of the script whenever the triggers change
  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = "chmod +x ./templates/cron-image"
  }

  provisioner "local-exec" {
    command = "./templates/cron-image"
    environment = {
      namespace = kubernetes_namespace.app_environments.metadata[0].name
      region = var.app_region
      cluster_name = local.cluster_name
    }
  }
  depends_on = [null_resource.run_deployment_script]
}

data "external" "cron_file_content" {
  program = ["yq", "eval", "-j", ".", "${path.module}/cronImageValues.yaml"]
  depends_on = [null_resource.run_cron_script]
}

module "cronjob" {
  for_each = var.cron_jobs

  source        = "../../../zop-helm/cronjob"
  namespace     = kubernetes_namespace.app_environments.metadata[0].name
  name          = each.key

  image         = local.cron_all_images[each.key]
  image_pull_secrets = each.value.helm_configs != null ? (each.value.helm_configs.image_pull_secrets != null ? each.value.helm_configs.image_pull_secrets : [] ) : []
  http_port     = each.value.helm_configs != null ? (each.value.helm_configs.http_port != null ? each.value.helm_configs.http_port : 8000) : 8000
  metrics_port  = each.value.helm_configs != null ? (each.value.helm_configs.metrics_port != null ? each.value.helm_configs.metrics_port : 0) : 0
  min_cpu       = each.value.helm_configs != null ? (each.value.helm_configs.min_cpu != null ? each.value.helm_configs.min_cpu : "100m") : "100m"
  min_memory    = each.value.helm_configs != null ? (each.value.helm_configs.min_memory != null ? each.value.helm_configs.min_memory : "128M") : "128M"
  max_cpu       = each.value.helm_configs != null ? (each.value.helm_configs.max_cpu != null ? each.value.helm_configs.max_cpu : "500m") : "500m"
  max_memory    = each.value.helm_configs != null ? (each.value.helm_configs.max_memory != null ? each.value.helm_configs.max_memory : "512M") : "512M"
  env           = merge((each.value.helm_configs != null ? (each.value.helm_configs.env != null ? each.value.helm_configs.env : {}) : {}), (local.ssl ? {DB_ENABLE_SSL = true} : {DB_ENABLE_SSL = false}))
  app_secrets   = each.value.db_name != null || each.value.custom_secrets != null || each.value.datastore_configs != null ? ["${each.key}-application-secrets"] : []
  db_ssl_enabled   = local.ssl
  schedule      = each.value.helm_configs != null ? each.value.helm_configs.schedule : ""
  suspend       = each.value.helm_configs != null ? (each.value.helm_configs.suspend != null ? each.value.helm_configs.suspend : false) : false
  concurrency_policy = each.value.helm_configs != null ? (each.value.helm_configs.concurrency_policy != null ? each.value.helm_configs.concurrency_policy : "Replace" ) : "Replace"
  configmaps_list = each.value.helm_configs != null ? (each.value.helm_configs.configmaps_list != null ? concat(["${each.key}-infra", var.namespace, each.key], each.value.helm_configs.configmaps_list) : ["${each.key}-infra", var.namespace, each.key] ): ["${each.key}-infra", var.namespace, each.key]
  secrets_list    = each.value.helm_configs != null ? (each.value.helm_configs.secrets_list != null ?  each.value.helm_configs.secrets_list : [] ): []
  volume_mount_configmaps  = each.value.helm_configs != null ? ( each.value.helm_configs.volume_mounts != null ? (each.value.helm_configs.volume_mounts.configmaps != null ? each.value.helm_configs.volume_mounts.configmaps : {}) : {} ) : {}
  volume_mount_secrets     = each.value.helm_configs != null ? ( each.value.helm_configs.volume_mounts != null ? (each.value.helm_configs.volume_mounts.secrets != null ? each.value.helm_configs.volume_mounts.secrets : {}) : {} ) : {}
  volume_mount_pvc      = coalesce(each.value.badger_db, false) ? local.badger_db_volume_mounts_crons[each.key] : {}
  infra_alerts     = each.value.helm_configs != null ? (each.value.helm_configs.infra_alerts != null ? each.value.helm_configs.infra_alerts : null ) : null

  depends_on = [module.rds, module.rds_v2, module.local_redis]
}