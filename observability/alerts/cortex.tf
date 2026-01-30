locals {
  cortex_alerts = local.configure_cortex_alerts ? templatefile(
    "${path.module}/templates/cortex-alerts.yaml",
    {
      cluster_name = var.cluster_name
      distributor_replica_threshold = try(var.cortex.alerts.distributor_replica, 1)
      ingester_replica_threshold = try(var.cortex.alerts.ingester_replica, 2)
      querier_replica_threshold = try(var.cortex.alerts.querier_replica, 3)
      queryfrontend_replica_threshold = try(var.cortex.alerts.query_frontend_replica, 1)
    }
  ) : null
}

resource "kubectl_manifest" "cortex_alerts" {
  count = local.configure_cortex_alerts ? 1 : 0
  yaml_body  = local.cortex_alerts
}