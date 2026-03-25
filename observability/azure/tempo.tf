locals {
  # this is metrics generator remote write configs
  remote_write_config = try([
    for remote in var.tempo.metrics_generator.remote_write : {
      host  = remote.host
      key   = remote.header.key
      value = remote.header.value
    }
  ], {})
}

resource "azurerm_storage_container" "tempo_container" {
  count                 = local.enable_tempo ? 1 : 0
  name                  = "${local.cluster_name}-tempo-container-${var.observability_suffix}"
  storage_account_name  = var.storage_account
  container_access_type = "private"
}


data "template_file" "tempo_template"{
  count = local.enable_tempo ? 1 : 0
  template = file("${path.module}/templates/tempo-values.yaml")
  vars = {
    "CONTAINER"                                          = azurerm_storage_container.tempo_container[0].name
    "STORAGE_ACCOUNT"                                    = var.storage_account
    "ACCOUNT_KEY"                                        = var.account_access_key
    ingester_replicas                                    = try(var.tempo.ingester.replicas != null ? var.tempo.ingester.replicas : "1", "1")
    ingester_min_memory                                  = try(var.tempo.ingester.min_memory != null ? var.tempo.ingester.min_memory : "1Gi", "1Gi")
    ingester_max_memory                                  = try(var.tempo.ingester.max_memory != null ? var.tempo.ingester.max_memory : "null", "null")
    ingester_min_cpu                                     = try(var.tempo.ingester.min_cpu != null ? var.tempo.ingester.min_cpu : "null", "null")
    ingester_max_cpu                                     = try(var.tempo.ingester.max_cpu != null ? var.tempo.ingester.max_cpu : "null", "null")
    ingester_autoscaling                                 = try(var.tempo.ingester.autoscaling != null ? var.tempo.ingester.autoscaling : "true", "true")
    ingester_min_replicas                                = try(var.tempo.ingester.min_replicas != null ? var.tempo.ingester.min_replicas : "2", "2")
    ingester_max_replicas                                = try(var.tempo.ingester.max_replicas != null ? var.tempo.ingester.max_replicas : "30", "30")
    ingester_memory_utilization                          = try(var.tempo.ingester.memory_utilization != null ? var.tempo.ingester.memory_utilization : "", "")
    ingester_cpu_utilization                             = try(var.tempo.ingester.cpu_utilization != null ? var.tempo.ingester.cpu_utilization : "", "")
    distributor_replicas                                 = try(var.tempo.distributor.replicas != null ? var.tempo.distributor.replicas : "1", "1")
    distributor_min_memory                               = try(var.tempo.distributor.min_memory != null ? var.tempo.distributor.min_memory : "750Mi", "750Mi")
    distributor_max_memory                               = try(var.tempo.distributor.max_memory != null ? var.tempo.distributor.max_memory : "null", "null")
    distributor_min_cpu                                  = try(var.tempo.distributor.min_cpu != null ? var.tempo.distributor.min_cpu : "null", "null")
    distributor_max_cpu                                  = try(var.tempo.distributor.max_cpu != null ? var.tempo.distributor.max_cpu : "null", "null")
    distributor_autoscaling                              = try(var.tempo.distributor.autoscaling != null ? var.tempo.distributor.autoscaling : "true", "true")
    distributor_min_replicas                             = try(var.tempo.distributor.min_replicas != null ? var.tempo.distributor.min_replicas : "2", "2")
    distributor_max_replicas                             = try(var.tempo.distributor.max_replicas != null ? var.tempo.distributor.max_replicas : "30", "30")
    distributor_memory_utilization                       = try(var.tempo.distributor.memory_utilization != null ? var.tempo.distributor.memory_utilization : "", "")
    distributor_cpu_utilization                          = try(var.tempo.distributor.cpu_utilization != null ? var.tempo.distributor.cpu_utilization : "","")
    querier_replicas                                     = try(var.tempo.querier.replicas != null ? var.tempo.querier.replicas : "1", "1")
    queryFrontend_replicas                               = try(var.tempo.queryFrontend.replicas != null ? var.tempo.queryFrontend.replicas : "1", "1")
    metrics_generator_enable                             = try(var.tempo.metrics_generator.enable != null ? var.tempo.metrics_generator.enable : false, false)
    metrics_generator_replicas                           = try(var.tempo.metrics_generator.replicas != null ? var.tempo.metrics_generator.replicas : "1", "1")
    metrics_generator_service_graphs_max_items           = try(var.tempo.metrics_generator.service_graphs_max_items != null ? var.tempo.metrics_generator.service_graphs_max_items : "30000", "30000")
    metrics_generator_service_graphs_wait                = try(var.tempo.metrics_generator.service_graphs_wait != null ? var.tempo.metrics_generator.service_graphs_wait : "30s", "30s")
    metrics_generator_remote_write_flush_deadline        = try(var.tempo.metrics_generator.remote_write_flush_deadline != null ? var.tempo.metrics_generator.remote_write_flush_deadline : "2m", "2m")
    metrics_generator_remote_write                       = jsonencode(local.remote_write_config)
    metrics_generator_metrics_ingestion_time_range_slack = try(var.tempo.metrics_generator.metrics_ingestion_time_range_slack != null ? var.tempo.metrics_generator.metrics_ingestion_time_range_slack : "40s", "40s")
  }
}

resource "helm_release" "tempo" {
  count      = local.enable_tempo ? 1 : 0
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo-distributed"
  namespace  = "tempo"
  version    = "1.38.0"

  values     =  [
    data.template_file.tempo_template[0].rendered
  ]
}