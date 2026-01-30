locals {
  tempo_alerts = local.configure_tempo_alerts ? templatefile(
    "${path.module}/templates/tempo-alerts.yaml",
    {
      cluster_name = var.cluster_name
      ingester_bytes_received_threshold = try(var.tempo.alerts.ingester_bytes_received, 0)
      distributor_ingester_appends_threshold = try(var.tempo.alerts.distributor_ingester_appends, 0)
      distributor_ingester_append_failures_threshold = try(var.tempo.alerts.distributor_ingester_append_failures, 2000)
      ingester_live_traces_threshold = try(var.tempo.alerts.ingester_live_traces, 20000)
      distributor_spans_received_threshold = try(var.tempo.alerts.distributor_spans_received, 0)
      distributor_bytes_received_threshold = try(var.tempo.alerts.distributor_bytes_received, 0)
      ingester_blocks_flushed_threshold = try(var.tempo.alerts.ingester_blocks_flushed, 0)
      tempodb_blocklist_threshold = try(var.tempo.alerts.tempodb_blocklist, 2000)
      distributor_replica_threshold = try(var.tempo.alerts.distributor_replica, 1)
      ingester_replica_threshold = try(var.tempo.alerts.ingester_replica, 1)
      querier_replica_threshold = try(var.tempo.alerts.querier_replica, 1)
      queryfrontend_replica_threshold = try(var.tempo.alerts.query_frontend_replica, 1)
    }
  ) : null
}

resource "kubectl_manifest" "tempo_alerts" {
  count = local.configure_tempo_alerts ? 1 : 0
  yaml_body  = local.tempo_alerts
}