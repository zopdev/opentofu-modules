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

  cron_jobs_acr_name_map = {
    for service_key, service_config in var.cron_jobs : service_key => coalesce(service_config.acr_name, service_key)
  }

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
      resource_group_name = var.resource_group_name
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
  env           = (each.value.helm_configs != null ? (each.value.helm_configs.env != null ? each.value.helm_configs.env : {}) : {})
  env_list       = each.value.helm_configs != null ? each.value.helm_configs.env_list != null ? each.value.helm_configs.env_list : null : null
  app_secrets   = each.value.db_name != null || each.value.custom_secrets != null || each.value.datastore_configs != null || each.value.redis == true || each.value.redis_configs != null ? ["${each.key}-application-secrets"] : []
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

  depends_on = [module.postgresql, module.postgres_v2, module.mysql, module.mysql_v2, module.local_redis]

}

resource "azuread_application" "cron_acr_sp" {
  for_each            = var.cron_jobs
  display_name               = "${local.cluster_name}-${var.namespace}-${each.key}"
}

resource "azuread_service_principal" "cron_acr_sp" {
  for_each            = var.cron_jobs
  account_enabled     = true
  application_id = azuread_application.cron_acr_sp[each.key].application_id
}

resource "azuread_service_principal_password" "cron_acr_sp_pwd" {
  for_each            = var.cron_jobs
  service_principal_id = azuread_service_principal.cron_acr_sp[each.key].id
}

data "azurerm_container_registry" "cron_acr" {
  for_each            = local.cron_jobs_acr_name_map
  name                = each.value
  resource_group_name = var.cron_jobs[each.key].acr_resource_group != null ? var.cron_jobs[each.key].acr_resource_group : var.resource_group_name
}

resource "azurerm_role_assignment" "cron_acr_access" {
  for_each             = local.cron_jobs_acr_name_map
  scope                = data.azurerm_container_registry.cron_acr[each.key].id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.cron_acr_sp[each.key].id
}

resource "azurerm_role_assignment" "cron_namespace_deployment_access" {
  for_each             = var.cron_jobs
  scope                = "${data.azurerm_kubernetes_cluster.cluster.id}/namespace/${var.namespace}"
  role_definition_name = "Azure Kubernetes Service RBAC Writer"
  principal_id         = azuread_service_principal. cron_acr_sp[each.key].id

  depends_on = [
    azuread_service_principal_password.cron_acr_sp_pwd
  ]
}