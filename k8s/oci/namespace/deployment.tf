locals {

  deployment_image_file_content = data.external.deployment_file_content.result != null ? data.external.deployment_file_content.result : {}

  deployment_api_image_map = { # Create a map to store API names and image versions
    for k, v in local.deployment_image_file_content : k => v
  }

  deployment_existing_images = tomap({
    for k,v in var.services : k => local.deployment_api_image_map[k] if contains(keys(local.deployment_api_image_map), k )
  })

  deployment_new_images = tomap({
    for k, v in var.services : k => (
      v.helm_configs != null
        ? (
            v.helm_configs.image != null && v.helm_configs.image != ""
              ? v.helm_configs.image
              : "zopdev/sample-go-api:latest"
          )
        : "zopdev/sample-go-api:latest"
    ) if !contains(keys(local.deployment_api_image_map), k)
  })
  
  deployment_all_images = merge(local.deployment_existing_images, local.deployment_new_images)

}

resource "null_resource" "run_deployment_script" {
  # Use triggers to force the execution of the script whenever the triggers change
  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = "chmod +x ./templates/deployment-image"
  }

  provisioner "local-exec" {
    command = "./templates/deployment-image"
    environment = {
      namespace = kubernetes_namespace.app_environments.metadata[0].name
      compartment_id = var.provider_id
      cluster_id = local.cluster_id
      region = var.app_region
    }
  }
}

data "external" "deployment_file_content" {
  program = ["yq", "eval", "-j", ".", "${path.module}/imageValues.yaml"]
  depends_on = [null_resource.run_deployment_script]
}

module "service_deployment" {
  for_each = var.services

  source        = "../../../zop-helm/service"
  namespace     = kubernetes_namespace.app_environments.metadata[0].name
  name          = each.key

  image         = local.deployment_all_images[each.key]
  image_pull_secrets = each.value.helm_configs != null ? (each.value.helm_configs.image_pull_secrets != null ? each.value.helm_configs.image_pull_secrets : [] ) : []
  replica_count = each.value.helm_configs != null ? (each.value.helm_configs.replica_count != null ? each.value.helm_configs.replica_count : 2) : 2
  cli_service   = each.value.helm_configs != null ? (each.value.helm_configs.cli_service != null ? each.value.helm_configs.cli_service : false) : false
  http_port     = each.value.helm_configs != null ? (each.value.helm_configs.http_port != null ? each.value.helm_configs.http_port : 8000) : 8000
  metrics_port  = each.value.helm_configs != null ? (each.value.helm_configs.metrics_port != null ? each.value.helm_configs.metrics_port : 0) : 0
  ports         = each.value.helm_configs != null ? (each.value.helm_configs.ports != null ? each.value.helm_configs.ports : {}) : {}
  min_cpu       = each.value.helm_configs != null ? (each.value.helm_configs.min_cpu != null ? each.value.helm_configs.min_cpu : "100m") : "100m"
  min_memory    = each.value.helm_configs != null ? (each.value.helm_configs.min_memory != null ? each.value.helm_configs.min_memory : "128M") : "128M"
  max_cpu       = each.value.helm_configs != null ? (each.value.helm_configs.max_cpu != null ? each.value.helm_configs.max_cpu : "500m") : "500m"
  max_memory    = each.value.helm_configs != null ? (each.value.helm_configs.max_memory != null ? each.value.helm_configs.max_memory : "512M") : "512M"
  min_available = each.value.helm_configs != null ? (each.value.helm_configs.min_available != null ? each.value.helm_configs.min_available : 1) : 1
  hpa_enable    = each.value.helm_configs != null ? (each.value.helm_configs.hpa!= null ? (each.value.helm_configs.hpa.enable != null ? each.value.helm_configs.hpa.enable : true) : true) : true
  hpa_min_replicas  = each.value.helm_configs != null ? (each.value.helm_configs.hpa!= null ? (each.value.helm_configs.hpa.min_replicas != null ? each.value.helm_configs.hpa.min_replicas : 2) : 2) : 2
  hpa_max_replicas  = each.value.helm_configs != null ? (each.value.helm_configs.hpa!= null ? (each.value.helm_configs.hpa.max_replicas != null ? each.value.helm_configs.hpa.max_replicas : 4) : 4) : 4
  hpa_cpu_limit     = each.value.helm_configs != null ? (each.value.helm_configs.hpa!= null ? (each.value.helm_configs.hpa.cpu_limit != null ? each.value.helm_configs.hpa.cpu_limit : "null") : "null"): "null"
  hpa_memory_limit  = each.value.helm_configs != null ? (each.value.helm_configs.hpa!= null ? (each.value.helm_configs.hpa.memory_limit != null ? each.value.helm_configs.hpa.memory_limit : "null") : "null") : "null"
  heartbeat_url  = each.value.helm_configs != null ? (each.value.helm_configs.heartbeat_url != null ? each.value.helm_configs.heartbeat_url : "") : ""
  env            = (each.value.helm_configs != null ? (each.value.helm_configs.env != null ? each.value.helm_configs.env : {}) : {})
  env_list       = each.value.helm_configs != null ? each.value.helm_configs.env_list != null ? each.value.helm_configs.env_list : null : null
  enable_readiness_probe = each.value.helm_configs != null ? (each.value.helm_configs.readiness_probes != null ? (each.value.helm_configs.readiness_probes.enable != null ? each.value.helm_configs.readiness_probes.enable : false) : false) : false
  enable_liveness_probe  = each.value.helm_configs != null ? (each.value.helm_configs.liveness_probes != null ? (each.value.helm_configs.liveness_probes.enable != null ? each.value.helm_configs.liveness_probes.enable : false) : false) : false
  readiness_initial_delay_seconds = each.value.helm_configs != null ? (each.value.helm_configs.readiness_probes != null ? (each.value.helm_configs.readiness_probes.initial_delay_seconds != null ? each.value.helm_configs.readiness_probes.initial_delay_seconds : 3) : 3) : 3
  readiness_period_seconds  = each.value.helm_configs != null ? (each.value.helm_configs.readiness_probes != null ? (each.value.helm_configs.readiness_probes.period_seconds != null ? each.value.helm_configs.readiness_probes.period_seconds : 10) : 10) : 10
  readiness_timeout_seconds = each.value.helm_configs != null ? (each.value.helm_configs.readiness_probes != null ? (each.value.helm_configs.readiness_probes.timeout_seconds != null ? each.value.helm_configs.readiness_probes.timeout_seconds : 3) : 3 ) : 3
  readiness_failure_threshold    = each.value.helm_configs != null ? (each.value.helm_configs.readiness_probes != null ? (each.value.helm_configs.readiness_probes.failure_threshold != null ? each.value.helm_configs.readiness_probes.failure_threshold : 3) : 3 ) : 3
  liveness_initial_delay_seconds = each.value.helm_configs != null ? (each.value.helm_configs.liveness_probes != null ? (each.value.helm_configs.liveness_probes.initial_delay_seconds != null ? each.value.helm_configs.liveness_probes.initial_delay_seconds : 3) : 3) : 3
  liveness_period_seconds  = each.value.helm_configs != null ? (each.value.helm_configs.liveness_probes != null ? (each.value.helm_configs.liveness_probes.period_seconds != null ? each.value.helm_configs.liveness_probes.period_seconds : 10) : 10) : 10
  liveness_timeout_seconds = each.value.helm_configs != null ? (each.value.helm_configs.liveness_probes != null ? (each.value.helm_configs.liveness_probes.timeout_seconds != null ? each.value.helm_configs.liveness_probes.timeout_seconds : 3) : 3) : 3
  liveness_failure_threshold = each.value.helm_configs != null ? (each.value.helm_configs.liveness_probes != null ? (each.value.helm_configs.liveness_probes.failure_threshold != null ? each.value.helm_configs.liveness_probes.failure_threshold : 3) : 3) : 3
  configmaps_list = each.value.helm_configs != null ? (each.value.helm_configs.configmaps_list != null ? concat(["${each.key}-infra", var.namespace, each.key], each.value.helm_configs.configmaps_list) : ["${each.key}-infra", var.namespace, each.key] ): ["${each.key}-infra", var.namespace, each.key]
  app_secrets     = each.value.db_name != null || each.value.custom_secrets != null || each.value.datastore_configs != null ? ["${each.key}-application-secrets"] : []
  secrets_list    = each.value.helm_configs != null ? (each.value.helm_configs.secrets_list != null ?  each.value.helm_configs.secrets_list : [] ): []
  volume_mount_configmaps  = each.value.helm_configs != null ? ( each.value.helm_configs.volume_mounts != null ? (each.value.helm_configs.volume_mounts.configmaps != null ? each.value.helm_configs.volume_mounts.configmaps : {}) : {} ) : {}
  volume_mount_secrets  = each.value.helm_configs != null ? ( each.value.helm_configs.volume_mounts != null ? (each.value.helm_configs.volume_mounts.secrets != null ? each.value.helm_configs.volume_mounts.secrets : {}) : {} ) : {}
  volume_mount_pvc_badger      = coalesce(each.value.badger_db, false) ? local.badger_db_volume_mounts_services[each.key] : {}
  volume_mount_pvc =  each.value.helm_configs != null ? ( each.value.helm_configs.volume_mounts != null ? (each.value.helm_configs.volume_mounts.pvc != null ? each.value.helm_configs.volume_mounts.pvc : {}) : {} ) : {}
  db_ssl_enabled   = local.ssl
  infra_alerts     = each.value.helm_configs != null ? (each.value.helm_configs.infra_alerts != null ? each.value.helm_configs.infra_alerts : null ) : null
  command = each.value.helm_configs != null ? (each.value.helm_configs.command != null ? each.value.helm_configs.command : null ) : null

  depends_on = [ module.sql_db, module.psql_db]
}