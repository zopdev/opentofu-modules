data "template_file" "tempo_alerts" {
  count = local.configure_tempo_alerts ? 1 : 0
  template = file("${path.module}/templates/tempo-alerts.yaml")
  vars     = {
    cluster_name = var.cluster_name
    ingester_bytes_received_threshold = var.tempo.alerts == null ? 0 : (var.tempo.alerts.ingester_bytes_received == null ? 0: var.tempo.alerts.ingester_bytes_received)
    distributor_ingester_appends_threshold = var.tempo.alerts == null ? 0 : (var.tempo.alerts.distributor_ingester_appends == null ? 0 : var.tempo.alerts.distributor_ingester_appends)
    distributor_ingester_append_failures_threshold = var.tempo.alerts == null ? 2000 : (var.tempo.alerts.distributor_ingester_append_failures == null ? 2000 : var.tempo.alerts.distributor_ingester_append_failures)
    ingester_live_traces_threshold = var.tempo.alerts == null ? 20000 : (var.tempo.alerts.ingester_live_traces == null ? 20000 : var.tempo.alerts.ingester_live_traces)
    distributor_spans_received_threshold = var.tempo.alerts == null ? 0 : (var.tempo.alerts.distributor_spans_received == null ? 0 : var.tempo.alerts.distributor_spans_received)
    distributor_bytes_received_threshold = var.tempo.alerts == null ? 0 : (var.tempo.alerts.distributor_bytes_received == null ? 0 : var.tempo.alerts.distributor_bytes_received)
    ingester_blocks_flushed_threshold = var.tempo.alerts == null ? 0 : (var.tempo.alerts.ingester_blocks_flushed == null ? 0 : var.tempo.alerts.ingester_blocks_flushed)
    tempodb_blocklist_threshold = var.tempo.alerts == null ? 2000 : (var.tempo.alerts.tempodb_blocklist == null ? 2000 : var.tempo.alerts.tempodb_blocklist)
    distributor_replica_threshold = var.tempo.alerts == null ? 1 : (var.tempo.alerts.distributor_replica == null ? 1 : var.tempo.alerts.distributor_replica)
    ingester_replica_threshold  = var.tempo.alerts == null ? 1 : (var.tempo.alerts.ingester_replica == null ? 1 : var.tempo.alerts.ingester_replica)
    querier_replica_threshold  = var.tempo.alerts == null ? 1 : (var.tempo.alerts.querier_replica == null ? 1 : var.tempo.alerts.querier_replica)
    queryfrontend_replica_threshold  = var.tempo.alerts == null ? 1 : (var.tempo.alerts.query_frontend_replica == null ? 1 : var.tempo.alerts.query_frontend_replica)
  }
}

resource "kubectl_manifest" "tempo_alerts" {
  count = local.configure_tempo_alerts ? 1 : 0
  yaml_body  = data.template_file.tempo_alerts[0].rendered
}

data "template_file" "tempo_alerts_configmap" {
  template = file("${path.module}/templates/configmaps/tempo-alerts.yaml")
  vars     = {
    cluster_name = var.cluster_name
    ingester_bytes_received_threshold = var.tempo.alerts == null ? 0 : (var.tempo.alerts.ingester_bytes_received == null ? 0: var.tempo.alerts.ingester_bytes_received)
    distributor_ingester_appends_threshold = var.tempo.alerts == null ? 0 : (var.tempo.alerts.distributor_ingester_appends == null ? 0 : var.tempo.alerts.distributor_ingester_appends)
    distributor_ingester_append_failures_threshold = var.tempo.alerts == null ? 2000 : (var.tempo.alerts.distributor_ingester_append_failures == null ? 2000 : var.tempo.alerts.distributor_ingester_append_failures)
    ingester_live_traces_threshold = var.tempo.alerts == null ? 20000 : (var.tempo.alerts.ingester_live_traces == null ? 20000 : var.tempo.alerts.ingester_live_traces)
    distributor_spans_received_threshold = var.tempo.alerts == null ? 0 : (var.tempo.alerts.distributor_spans_received == null ? 0 : var.tempo.alerts.distributor_spans_received)
    distributor_bytes_received_threshold = var.tempo.alerts == null ? 0 : (var.tempo.alerts.distributor_bytes_received == null ? 0 : var.tempo.alerts.distributor_bytes_received)
    ingester_blocks_flushed_threshold = var.tempo.alerts == null ? 0 : (var.tempo.alerts.ingester_blocks_flushed == null ? 0 : var.tempo.alerts.ingester_blocks_flushed)
    tempodb_blocklist_threshold = var.tempo.alerts == null ? 2000 : (var.tempo.alerts.tempodb_blocklist == null ? 2000 : var.tempo.alerts.tempodb_blocklist)
    distributor_replica_threshold = var.tempo.alerts == null ? 1 : (var.tempo.alerts.distributor_replica == null ? 1 : var.tempo.alerts.distributor_replica)
    ingester_replica_threshold  = var.tempo.alerts == null ? 1 : (var.tempo.alerts.ingester_replica == null ? 1 : var.tempo.alerts.ingester_replica)
    querier_replica_threshold  = var.tempo.alerts == null ? 1 : (var.tempo.alerts.querier_replica == null ? 1 : var.tempo.alerts.querier_replica)
    queryfrontend_replica_threshold  = var.tempo.alerts == null ? 1 : (var.tempo.alerts.query_frontend_replica == null ? 1 : var.tempo.alerts.query_frontend_replica)
  }
}

resource "kubectl_manifest" "tempo_alerts_configmap" {
  count = local.enable_otel ? 1 : 0
  yaml_body  = data.template_file.tempo_alerts.rendered
}