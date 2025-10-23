data "template_file" "loki_alerts" {
  count = local.configure_loki_alerts ? 1 : 0
  template = file("${path.module}/templates/loki-alerts.yaml")
  vars     = {
    cluster_name = var.cluster_name
    distributor_lines_received_threshold = var.loki.alerts == null ? 10000 : (var.loki.alerts.distributor_lines_received == null ? 10000: var.loki.alerts.distributor_lines_received)
    distributor_bytes_received_threshold = var.loki.alerts == null ? 0 : (var.loki.alerts.distributor_bytes_received == null ? 0: var.loki.alerts.distributor_bytes_received)
    distributor_appended_failures_threshold = var.loki.alerts == null ? 10000 : (var.loki.alerts.distributor_appended_failures == null ? 10000 : var.loki.alerts.distributor_appended_failures)
    request_errors_threshold = var.loki.alerts == null ? 10 : (var.loki.alerts.request_errors == null ? 10 : var.loki.alerts.request_errors)
    panics_threshold = var.loki.alerts == null ? 0 : (var.loki.alerts.panics == null ? 0 : var.loki.alerts.panics)
    request_latency_threshold = var.loki.alerts == null ? 1 : (var.loki.alerts.request_latency == null ? 1 : var.loki.alerts.request_latency)
    distributor_replica_threshold = var.loki.alerts == null ? 1 : (var.loki.alerts.distributor_replica == null ? 1 : var.loki.alerts.distributor_replica)
    ingester_replica_threshold  = var.loki.alerts == null ? 1 : (var.loki.alerts.ingester_replica == null ? 1 : var.loki.alerts.ingester_replica)
    querier_replica_threshold  = var.loki.alerts == null ? 4 : (var.loki.alerts.querier_replica == null ? 4 : var.loki.alerts.querier_replica)
    queryfrontend_replica_threshold  = var.loki.alerts == null ? 1 : (var.loki.alerts.query_frontend_replica == null ? 1 : var.loki.alerts.query_frontend_replica)
  }
}

resource "kubectl_manifest" "loki_alerts" {
  count = local.configure_loki_alerts ? 1 : 0
  yaml_body  = data.template_file.loki_alerts[0].rendered
}

data "template_file" "loki_alerts_configmap" {
  count = local.enable_otel ? 1 : 0
  template = file("${path.module}/templates/configmaps/loki-alerts.yaml")
  vars = {
    cluster_name = var.cluster_name
    distributor_lines_received_threshold = var.loki.alerts == null ? 10000 : (var.loki.alerts.distributor_lines_received == null ? 10000: var.loki.alerts.distributor_lines_received)
    distributor_bytes_received_threshold = var.loki.alerts == null ? 0 : (var.loki.alerts.distributor_bytes_received == null ? 0: var.loki.alerts.distributor_bytes_received)
    distributor_appended_failures_threshold = var.loki.alerts == null ? 10000 : (var.loki.alerts.distributor_appended_failures == null ? 10000 : var.loki.alerts.distributor_appended_failures)
    request_errors_threshold = var.loki.alerts == null ? 10 : (var.loki.alerts.request_errors == null ? 10 : var.loki.alerts.request_errors)
    panics_threshold = var.loki.alerts == null ? 0 : (var.loki.alerts.panics == null ? 0 : var.loki.alerts.panics)
    request_latency_threshold = var.loki.alerts == null ? 1 : (var.loki.alerts.request_latency == null ? 1 : var.loki.alerts.request_latency)
    distributor_replica_threshold = var.loki.alerts == null ? 1 : (var.loki.alerts.distributor_replica == null ? 1 : var.loki.alerts.distributor_replica)
    ingester_replica_threshold  = var.loki.alerts == null ? 1 : (var.loki.alerts.ingester_replica == null ? 1 : var.loki.alerts.ingester_replica)
    querier_replica_threshold  = var.loki.alerts == null ? 4 : (var.loki.alerts.querier_replica == null ? 4 : var.loki.alerts.querier_replica)
    queryfrontend_replica_threshold  = var.loki.alerts == null ? 1 : (var.loki.alerts.query_frontend_replica == null ? 1 : var.loki.alerts.query_frontend_replica)
  }
}

resource "kubectl_manifest" "loki_alerts_configmap" {
  count      = local.enable_otel ? 1 : 0
  yaml_body  = data.template_file.loki_alerts_configmap.rendered
}