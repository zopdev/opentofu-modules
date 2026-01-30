locals {
  mimir_alerts = local.configure_mimir_alerts ? templatefile(
    "${path.module}/templates/mimir-alerts.yaml",
    {
      cluster_name = var.cluster_name
      distributor_replica_threshold = try(var.mimir.alerts.distributor_replica, 1)
      ingester_replica_threshold = try(var.mimir.alerts.ingester_replica, 2)
      querier_replica_threshold = try(var.mimir.alerts.querier_replica, 3)
      queryfrontend_replica_threshold = try(var.mimir.alerts.query_frontend_replica, 1)
    }
  ) : null
}

resource "kubectl_manifest" "mimir_alerts" {
  count = local.configure_mimir_alerts ? 1 : 0
  yaml_body  = local.mimir_alerts
}