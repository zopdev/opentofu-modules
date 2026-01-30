locals {
  loki_values = local.enable_loki ? templatefile("${path.module}/templates/loki-values.yaml", {
    CONTAINER                   = azurerm_storage_container.loki_container[0].name
    STORAGE_ACCOUNT             = var.storage_account
    ACCOUNT_KEY                 = var.account_access_key

    # Ingester
    ingester_replicas           = try(var.loki.ingester.replicas, "1")
    ingester_min_memory         = try(var.loki.ingester.min_memory, "1Gi")
    ingester_max_memory         = try(var.loki.ingester.max_memory, null)
    ingester_min_cpu            = try(var.loki.ingester.min_cpu, null)
    ingester_max_cpu            = try(var.loki.ingester.max_cpu, null)
    ingester_autoscaling        = try(var.loki.ingester.autoscaling, "true")
    ingester_min_replicas       = try(var.loki.ingester.min_replicas, "2")
    ingester_max_replicas       = try(var.loki.ingester.max_replicas, "30")
    ingester_memory_utilization = try(var.loki.ingester.memory_utilization, "")
    ingester_cpu_utilization    = try(var.loki.ingester.cpu_utilization, "")

    # Distributor
    distributor_replicas           = try(var.loki.distributor.replicas, "1")
    distributor_min_memory         = try(var.loki.distributor.min_memory, "512Mi")
    distributor_max_memory         = try(var.loki.distributor.max_memory, "1Gi")
    distributor_min_cpu            = try(var.loki.distributor.min_cpu, "250m")
    distributor_max_cpu            = try(var.loki.distributor.max_cpu, "1")
    distributor_autoscaling        = try(var.loki.distributor.autoscaling, "true")
    distributor_min_replicas       = try(var.loki.distributor.min_replicas, "2")
    distributor_max_replicas       = try(var.loki.distributor.max_replicas, "30")
    distributor_memory_utilization = try(var.loki.distributor.memory_utilization, "")
    distributor_cpu_utilization    = try(var.loki.distributor.cpu_utilization, "")

    # Querier
    querier_replicas           = try(var.loki.querier.replicas, "4")
    querier_min_memory         = try(var.loki.querier.min_memory, "500Mi")
    querier_max_memory         = try(var.loki.querier.max_memory, null)
    querier_min_cpu            = try(var.loki.querier.min_cpu, "100m")
    querier_max_cpu            = try(var.loki.querier.max_cpu, null)
    querier_autoscaling        = try(var.loki.querier.autoscaling, "true")
    querier_min_replicas       = try(var.loki.querier.min_replicas, "2")
    querier_max_replicas       = try(var.loki.querier.max_replicas, "6")
    querier_memory_utilization = try(var.loki.querier.memory_utilization, "")
    querier_cpu_utilization    = try(var.loki.querier.cpu_utilization, "")
    querier_max_unavailable    = try(var.loki.querier.max_unavailable, "1")

    # Query Frontend
    queryFrontend_replicas           = try(var.loki.queryFrontend.replicas, "1")
    queryFrontend_min_memory         = try(var.loki.queryFrontend.min_memory, "250Mi")
    queryFrontend_max_memory         = try(var.loki.queryFrontend.max_memory, null)
    queryFrontend_min_cpu            = try(var.loki.queryFrontend.min_cpu, null)
    queryFrontend_max_cpu            = try(var.loki.queryFrontend.max_cpu, null)
    queryFrontend_autoscaling        = try(var.loki.queryFrontend.autoscaling, "true")
    queryFrontend_min_replicas       = try(var.loki.queryFrontend.min_replicas, "1")
    queryFrontend_max_replicas       = try(var.loki.queryFrontend.max_replicas, "6")
    queryFrontend_memory_utilization = try(var.loki.queryFrontend.memory_utilization, "")
    queryFrontend_cpu_utilization    = try(var.loki.queryFrontend.cpu_utilization, "")
  }) : null
}

resource "azurerm_storage_container" "loki_container" {
  count                 = local.enable_loki ? 1 : 0
  name                  = "${local.cluster_name}-loki-container-${var.observability_suffix}"
  storage_account_name  = var.storage_account
  container_access_type = "private"
}

resource "helm_release" "loki" {
  count      = local.enable_loki ? 1 : 0
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-distributed"
  namespace  = "loki"
  version    = "0.68.0"

  values = [
    local.loki_values
  ]
}