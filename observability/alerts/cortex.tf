data "template_file" "cortex_alerts" {
  count = local.configure_cortex_alerts ? 1 : 0
  template = file("${path.module}/templates/cortex-alerts.yaml")
  vars     = {
    cluster_name = var.cluster_name
    distributor_replica_threshold = var.cortex.alerts == null ? 1 : (var.cortex.alerts.distributor_replica == null ? 1 : var.cortex.alerts.distributor_replica)
    ingester_replica_threshold  = var.cortex.alerts == null ? 2 : (var.cortex.alerts.ingester_replica == null ? 2 : var.cortex.alerts.ingester_replica)
    querier_replica_threshold  = var.cortex.alerts == null ? 3 : (var.cortex.alerts.querier_replica == null ? 3 : var.cortex.alerts.querier_replica)
    queryfrontend_replica_threshold  = var.cortex.alerts == null ? 1 : (var.cortex.alerts.query_frontend_replica == null ? 1 : var.cortex.alerts.query_frontend_replica)
  }
}

resource "kubectl_manifest" "cortex_alerts" {
  count = local.configure_cortex_alerts ? 1 : 0
  yaml_body  = data.template_file.cortex_alerts[0].rendered
}

data "template_file" "cortex_alerts_configmap" {
  template = file("${path.module}/templates/configmaps/cortex-alerts.yaml")
  vars = {
    cluster_name = var.cluster_name
    distributor_replica_threshold = var.cortex.alerts == null ? 1 : (var.cortex.alerts.distributor_replica == null ? 1 : var.cortex.alerts.distributor_replica)
    ingester_replica_threshold  = var.cortex.alerts == null ? 2 : (var.cortex.alerts.ingester_replica == null ? 2 : var.cortex.alerts.ingester_replica)
    querier_replica_threshold  = var.cortex.alerts == null ? 3 : (var.cortex.alerts.querier_replica == null ? 3 : var.cortex.alerts.querier_replica)
    queryfrontend_replica_threshold  = var.cortex.alerts == null ? 1 : (var.cortex.alerts.query_frontend_replica == null ? 1 : var.cortex.alerts.query_frontend_replica)
  }
}

resource "kubectl_manifest" "cortex_alerts_configmap" {
  count      = local.enable_otel ? 1 : 0
  yaml_body  = data.template_file.cortex_alerts_configmap.rendered
}