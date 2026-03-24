resource "azurerm_storage_container" "loki_container" {
  count                 = local.enable_loki ? 1 : 0
  name                  = "${local.cluster_name}-loki-container-${var.observability_suffix}"
  storage_account_name  = var.storage_account
  container_access_type = "private"
}


data "template_file" "loki_template" {
  count = local.enable_loki ? 1 : 0
  template = file("${path.module}/templates/loki-values.yaml")
  vars = {
    "CONTAINER"                       = azurerm_storage_container.loki_container[0].name
    "STORAGE_ACCOUNT"                 = var.storage_account
    "ACCOUNT_KEY"                     = var.account_access_key
    ingester_replicas               = try(var.loki.ingester.replicas != null ? var.loki.ingester.replicas : "1", "1")
    ingester_max_memory             = try(var.loki.ingester.max_memory != null ? var.loki.ingester.max_memory : "null", "null")
    ingester_min_memory             = try(var.loki.ingester.min_memory != null ? var.loki.ingester.min_memory : "1Gi", "1Gi")
    ingester_max_cpu                = try(var.loki.ingester.max_cpu != null ? var.loki.ingester.max_cpu : "null", "null")
    ingester_min_cpu                = try(var.loki.ingester.min_cpu != null ? var.loki.ingester.min_cpu : "null", "null")
    ingester_autoscaling            = try(var.loki.ingester.autoscaling != null ? var.loki.ingester.autoscaling : "true", "true")
    ingester_max_replicas           = try(var.loki.ingester.max_replicas != null ? var.loki.ingester.max_replicas : "30", "30")
    ingester_min_replicas           = try(var.loki.ingester.min_replicas != null ? var.loki.ingester.min_replicas : "2", "2")
    ingester_cpu_utilization        = try(var.loki.ingester.cpu_utilization != null ? var.loki.ingester.cpu_utilization : "", "")
    ingester_memory_utilization     = try(var.loki.ingester.memory_utilization != null ? var.loki.ingester.memory_utilization : "", "")
    distributor_replicas            = try(var.loki.distributor.replicas != null ? var.loki.distributor.replicas : "1", "1")
    distributor_max_memory          = try(var.loki.distributor.max_memory != null ? var.loki.distributor.max_memory : "1Gi", "1Gi")
    distributor_min_memory          = try(var.loki.distributor.min_memory != null ? var.loki.distributor.min_memory : "512Mi", "512Mi")
    distributor_max_cpu             = try(var.loki.distributor.max_cpu != null ? var.loki.distributor.max_cpu : "1", "1")
    distributor_min_cpu             = try(var.loki.distributor.min_cpu != null ? var.loki.distributor.min_cpu : "250m", "250m")
    distributor_autoscaling         = try(var.loki.distributor.autoscaling != null ? var.loki.distributor.autoscaling : "true", "true")
    distributor_max_replicas        = try(var.loki.distributor.max_replicas != null ? var.loki.distributor.max_replicas : "30", "30")
    distributor_min_replicas        = try(var.loki.distributor.min_replicas != null ? var.loki.distributor.min_replicas : "2", "2")
    distributor_memory_utilization  = try(var.loki.distributor.memory_utilization != null ? var.loki.distributor.memory_utilization : "", "")
    distributor_cpu_utilization     = try(var.loki.distributor.cpu_utilization != null ? var.loki.distributor.cpu_utilization : "", "")
    querier_replicas                = try(var.loki.querier.replicas != null ? var.loki.querier.replicas : "4", "4")
    querier_max_unavailable         = try(var.loki.querier.max_unavailable != null ? var.loki.querier.max_unavailable : "1", "1")
    querier_min_memory              = try(var.loki.querier.min_memory != null ? var.loki.querier.min_memory : "500Mi", "500Mi")
    querier_min_cpu                 = try(var.loki.querier.min_cpu != null ? var.loki.querier.min_cpu : "100m", "100m")
    querier_max_memory              = try(var.loki.querier.max_memory != null ? var.loki.querier.max_memory : "null", "null")
    querier_max_cpu                 = try(var.loki.querier.max_cpu != null ? var.loki.querier.max_cpu : "null", "null")
    querier_autoscaling             = try(var.loki.querier.autoscaling != null ? var.loki.querier.autoscaling : "true", "true")
    querier_max_replicas            = try(var.loki.querier.max_replicas != null ? var.loki.querier.max_replicas : "6", "6")
    querier_min_replicas            = try(var.loki.querier.min_replicas != null ? var.loki.querier.min_replicas : "2", "2")
    querier_memory_utilization      = try(var.loki.querier.memory_utilization != null ? var.loki.querier.memory_utilization : "", "")
    querier_cpu_utilization         = try(var.loki.querier.cpu_utilization != null ? var.loki.querier.cpu_utilization : "", "")
    queryFrontend_replicas          = try(var.loki.queryFrontend.replicas != null ? var.loki.queryFrontend.replicas : "1", "1")
    queryFrontend_min_memory        = try(var.loki.queryFrontend.min_memory != null ? var.loki.queryFrontend.min_memory : "250Mi", "250Mi")
    queryFrontend_max_memory        = try(var.loki.query_frontend.max_memory != null ? var.loki.query_frontend.max_memory : "null", "null")
    queryFrontend_min_cpu           = try(var.loki.query_frontend.min_cpu != null ? var.loki.query_frontend.min_cpu : "null", "null")
    queryFrontend_max_cpu           = try(var.loki.query_frontend.max_cpu != null ? var.loki.query_frontend.max_cpu : "null", "null")
    queryFrontend_autoscaling       = try(var.loki.queryFrontend.autoscaling != null ? var.loki.queryFrontend.autoscaling : "true", "true")
    queryFrontend_max_replicas      = try(var.loki.queryFrontend.max_replicas != null ? var.loki.queryFrontend.max_replicas : "6", "6")
    queryFrontend_min_replicas      = try(var.loki.queryFrontend.min_replicas != null ? var.loki.queryFrontend.min_replicas : "1", "1")
    queryFrontend_memory_utilization= try(var.loki.queryFrontend.memory_utilization != null ? var.loki.queryFrontend.memory_utilization : "", "")
    queryFrontend_cpu_utilization= try(var.loki.queryFrontend.cpu_utilization != null ? var.loki.queryFrontend.cpu_utilization : "", "")
  }
}

resource "helm_release" "loki" {
  count      = local.enable_loki ? 1 : 0
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-distributed"
  namespace  = "loki"
  version    = "0.68.0"

  values = [
    data.template_file.loki_template[0].rendered
  ]
}