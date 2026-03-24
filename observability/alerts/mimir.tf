data "template_file" "mimir_alerts" {
  count = local.configure_mimir_alerts ? 1 : 0
  template = file("${path.module}/templates/mimir-alerts.yaml")
  vars     = {
    cluster_name = var.cluster_name
    distributor_replica_threshold = var.mimir.alerts == null ? 1 : (var.mimir.alerts.distributor_replica == null ? 1 : var.mimir.alerts.distributor_replica)
    ingester_replica_threshold  = var.mimir.alerts == null ? 2 : (var.mimir.alerts.ingester_replica == null ? 2 : var.mimir.alerts.ingester_replica)
    querier_replica_threshold  = var.mimir.alerts == null ? 3 : (var.mimir.alerts.querier_replica == null ? 3 : var.mimir.alerts.querier_replica)
    queryfrontend_replica_threshold  = var.mimir.alerts == null ? 1 : (var.mimir.alerts.query_frontend_replica == null ? 1 : var.mimir.alerts.query_frontend_replica)
  }
}

resource "kubectl_manifest" "mimir_alerts" {
  count = local.configure_mimir_alerts ? 1 : 0
  yaml_body  = data.template_file.mimir_alerts[0].rendered
}