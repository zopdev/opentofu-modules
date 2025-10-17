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

data "template_file" "mimir_alerts_configmap" {
  template = file("${path.module}/templates/configmaps/mimir-alerts.yaml")
  vars     = {
    cluster_name = var.cluster_name
    distributor_replica_threshold = var.mimir.alerts == null ? 1 : (var.mimir.alerts.distributor_replica == null ? 1 : var.mimir.alerts.distributor_replica)
    ingester_replica_threshold  = var.mimir.alerts == null ? 2 : (var.mimir.alerts.ingester_replica == null ? 2 : var.mimir.alerts.ingester_replica)
    querier_replica_threshold  = var.mimir.alerts == null ? 3 : (var.mimir.alerts.querier_replica == null ? 3 : var.mimir.alerts.querier_replica)
    queryfrontend_replica_threshold  = var.mimir.alerts == null ? 1 : (var.mimir.alerts.query_frontend_replica == null ? 1 : var.mimir.alerts.query_frontend_replica)
  }
}

resource "kubectl_manifest" "mimir_alerts_configmap" {
  count      = local.enable_otel ? 1 : 0
  yaml_body  = data.template_file.mimir_alerts.rendered
  depends_on = [helm_release.mimir]
}

# Cluster-level alerts as ConfigMaps (used by Mimir Ruler)
data "template_file" "cluster_alerts" {
  template = file("${path.module}/templates/configmaps/cluster-level-alerts.yaml")
  vars = {
    cluster_memory_usage_request_underutilisation_threshold = var.cluster_alert_thresholds == null ? 20 : (var.cluster_alert_thresholds.memory_underutilisation != null ? var.cluster_alert_thresholds.memory_underutilisation : 20)
    cluster_cpu_usage_request_underutilisation_threshold = var.cluster_alert_thresholds == null ? 20 : (var.cluster_alert_thresholds.cpu_underutilisation != null ? var.cluster_alert_thresholds.cpu_underutilisation : 20)
    cluster_node_count_max_value = local.enable_monitoring_node_pool ? var.monitoring_node_config.max_count : var.node_config.max_count
    cluster_node_count_threshold = var.cluster_alert_thresholds == null ? 80 : (var.cluster_alert_thresholds.node_count != null ? var.cluster_alert_thresholds.node_count : 80)
    cluster_pod_count_threshold = var.cluster_alert_thresholds == null ? 80 : (var.cluster_alert_thresholds.pod_count != null ? var.cluster_alert_thresholds.pod_count: 80)
    cluster_total_cpu_utilization_threshold = var.cluster_alert_thresholds == null ? 80 : (var.cluster_alert_thresholds.cpu_utilisation != null ? var.cluster_alert_thresholds.cpu_utilisation: 80)
    cluster_total_memory_utilization_threshold = var.cluster_alert_thresholds == null ? 20 : (var.cluster_alert_thresholds.memory_utilisation != null ? var.cluster_alert_thresholds.memory_utilisation: 20)
    cluster_disk_utilization_threshold = var.cluster_alert_thresholds == null ? 80 : (var.cluster_alert_thresholds.disk_utilization != null ? var.cluster_alert_thresholds.disk_utilization: 80)
    cluster_name   = var.cluster_name
    cortex_enabled = try(var.cortex.enable == null ? false : var.cortex.enable, false)
    nginx_5xx_percentage_threshold = var.cluster_alert_thresholds == null ? 5 : (var.cluster_alert_thresholds.nginx_5xx_percentage_threshold != null ? var.cluster_alert_thresholds.nginx_5xx_percentage_threshold: 5)
    cortex_disk_utilization_threshold = var.cluster_alert_thresholds == null ? 80 : (var.cluster_alert_thresholds.cortex_disk_utilization_threshold != null ? var.cluster_alert_thresholds.cortex_disk_utilization_threshold : 80)
    prometheus_disk_utilization_threshold = var.cluster_alert_thresholds == null ? 80 : (var.cluster_alert_thresholds.prometheus_disk_utilization_threshold != null ? var.cluster_alert_thresholds.prometheus_disk_utilization_threshold : 80)
  }
}

resource "kubectl_manifest" "cluster_alerts_configmap" {
  count      = local.enable_otel ? 1 : 0
  yaml_body  = data.template_file.cluster_alerts.rendered
}