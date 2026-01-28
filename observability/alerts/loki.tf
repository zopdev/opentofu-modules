locals {
  loki_alerts = local.configure_loki_alerts ? templatefile(
    "${path.module}/templates/loki-alerts.yaml",
    {
      cluster_name = var.cluster_name
      distributor_lines_received_threshold = try(var.loki.alerts.distributor_lines_received, 10000)
      distributor_bytes_received_threshold = try(var.loki.alerts.distributor_bytes_received, 0)
      distributor_appended_failures_threshold = try(var.loki.alerts.distributor_appended_failures, 10000)
      request_errors_threshold = try(var.loki.alerts.request_errors, 10)
      panics_threshold = try(var.loki.alerts.panics, 0)
      request_latency_threshold = try(var.loki.alerts.request_latency, 1)
      distributor_replica_threshold = try(var.loki.alerts.distributor_replica, 1)
      ingester_replica_threshold = try(var.loki.alerts.ingester_replica, 1)
      querier_replica_threshold = try(var.loki.alerts.querier_replica, 4)
      queryfrontend_replica_threshold = try(var.loki.alerts.query_frontend_replica, 1)
    }
  ) : null
}

resource "kubectl_manifest" "loki_alerts" {
  count = local.configure_loki_alerts ? 1 : 0
  yaml_body  = local.loki_alerts
}