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

locals {
  tempo_values = local.enable_tempo ? templatefile("${path.module}/templates/tempo-values.yaml", {
    # Storage config
    CONTAINER       = azurerm_storage_container.tempo_container[0].name
    STORAGE_ACCOUNT = var.storage_account
    ACCOUNT_KEY     = var.account_access_key

    # Ingester
    ingester_replicas        = try(var.tempo.ingester.replicas, "1")
    ingester_min_memory      = try(var.tempo.ingester.min_memory, "1Gi")
    ingester_max_memory      = try(var.tempo.ingester.max_memory, null)
    ingester_min_cpu         = try(var.tempo.ingester.min_cpu, null)
    ingester_max_cpu         = try(var.tempo.ingester.max_cpu, null)
    ingester_autoscaling     = try(var.tempo.ingester.autoscaling, "true")
    ingester_min_replicas    = try(var.tempo.ingester.min_replicas, "2")
    ingester_max_replicas    = try(var.tempo.ingester.max_replicas, "30")
    ingester_memory_utilization = try(var.tempo.ingester.memory_utilization, "")
    ingester_cpu_utilization    = try(var.tempo.ingester.cpu_utilization, "")

    # Distributor
    distributor_replicas        = try(var.tempo.distributor.replicas, "1")
    distributor_min_memory      = try(var.tempo.distributor.min_memory, "750Mi")
    distributor_max_memory      = try(var.tempo.distributor.max_memory, null)
    distributor_min_cpu         = try(var.tempo.distributor.min_cpu, null)
    distributor_max_cpu         = try(var.tempo.distributor.max_cpu, null)
    distributor_autoscaling     = try(var.tempo.distributor.autoscaling, "true")
    distributor_min_replicas    = try(var.tempo.distributor.min_replicas, "2")
    distributor_max_replicas    = try(var.tempo.distributor.max_replicas, "30")
    distributor_memory_utilization = try(var.tempo.distributor.memory_utilization, "")
    distributor_cpu_utilization    = try(var.tempo.distributor.cpu_utilization, "")

    # Querier & Query Frontend
    querier_replicas        = try(var.tempo.querier.replicas, "1")
    query_frontend_replicas = try(var.tempo.queryFrontend.replicas, "1")

    # Metrics Generator
    metrics_generator_enable                             = try(var.tempo.metrics_generator.enable, false)
    metrics_generator_replicas                           = try(var.tempo.metrics_generator.replicas, "1")
    metrics_generator_service_graphs_max_items           = try(var.tempo.metrics_generator.service_graphs_max_items, "30000")
    metrics_generator_service_graphs_wait                = try(var.tempo.metrics_generator.service_graphs_wait, "30s")
    metrics_generator_remote_write_flush_deadline        = try(var.tempo.metrics_generator.remote_write_flush_deadline, "2m")
    metrics_generator_remote_write                       = jsonencode(local.remote_write_config)
    metrics_generator_metrics_ingestion_time_range_slack = try(var.tempo.metrics_generator.metrics_ingestion_time_range_slack, "40s")
  }) : null
}


resource "azurerm_storage_container" "tempo_container" {
  count                 = local.enable_tempo ? 1 : 0
  name                  = "${local.cluster_name}-tempo-container-${var.observability_suffix}"
  storage_account_name  = var.storage_account
  container_access_type = "private"
}

resource "helm_release" "tempo" {
  count      = local.enable_tempo ? 1 : 0
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo-distributed"
  namespace  = "tempo"
  version    = "1.38.0"

  values     =  [
    local.tempo_values
  ]
}