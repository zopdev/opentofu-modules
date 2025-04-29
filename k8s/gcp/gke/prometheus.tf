resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

locals{
  ### this app namespace level alerts:
  namespace_teams_webhook   =  merge([for n, s in var.app_namespaces : { for k, v in s.alert_webhooks : "namespace-webhook-${n}-${k}" => { data   = substr(v.data, 8, length(v.data)), labels = v.labels == null ? merge(v.labels, {severity = "critical", servicealert = "true",namespace = n}) : merge(v.labels, {namespace = n}), } if v.type == "teams"}if s.alert_webhooks != null]...)
  namespace_google_chat_alerts = merge([for n, s in var.app_namespaces : { for k, v in s.alert_webhooks : "namespace-webhook-${n}-${k}" => { data   = v.data, labels = v.labels == null ? merge(v.labels, {severity = "critical", servicealert = "true",namespace = n}) : merge(v.labels, {namespace = n}), } if v.type == "google_chat"}if s.alert_webhooks != null]...)

  ### this is cluster level alerts:
  cluster_teams_alerts      = jsonencode(var.cluster_alert_webhooks) == "" ? {} : { for key, val in var.cluster_alert_webhooks : "cluster-webhook-${key}" => { data = substr(val.data,8 ,length(val.data) ),labels = val.labels == null ? {severity = "critical", servicealert = "true"} : val.labels, } if val.type == "teams"}
  cluster_moogsoft_alerts   =  jsonencode(var.cluster_alert_webhooks) == "" ? {} : { for key, val in var.cluster_alert_webhooks : "moogsoft-webhook-${key}" => { data = val.data,labels = val.labels == null ? {severity = "critical", servicealert = "true"} : val.labels, } if val.type == "moogsoft"}
  cluster_pagerduty_alerts  = jsonencode(var.cluster_alert_webhooks) == "" ? {} : { for key, val in var.cluster_alert_webhooks : "pagerduty-webhook-${key}" => { data = val.data,labels = val.labels == null ? {severity = "critical", servicealert = "true"} : val.labels, } if val.type == "pagerduty"}
  cluster_google_chat_alerts= jsonencode(var.cluster_alert_webhooks) == "" ? {} : { for key, val in var.cluster_alert_webhooks : "google-chat-webhook-${key}" => {data = val.data, labels = val.labels == null ? {severity = "critical", servicealert = "true"} : val.labels, } if val.type == "google_chat"}
  cluster_alerts            = merge(local.namespace_teams_webhook,  local.cluster_teams_alerts)
  cluster_alerts_webhook    = merge(local.cluster_alerts, local.cluster_moogsoft_alerts, local.cluster_pagerduty_alerts)
  cluster_slack_alerts      = jsonencode(var.slack_alerts_configs) == "" ? {} : { for key, val in var.slack_alerts_configs : "slack-alert-${val.name}" => {url = val.url, channel = val.channel,labels = val.labels == null ? {severity = "critical", servicealert = "true"} : val.labels, }}
  google_chat_alerts        = merge( local.cluster_google_chat_alerts, local.namespace_google_chat_alerts)

  ## this is prometheus remote write configs
  remote_write_config_list = try([
    for remote in var.observability_config.prometheus.remote_write : {
      host  = remote.host
      key   = remote.header.key
      value = remote.header.value
    }
  ], [])

  default_remote_write_config = local.enable_mimir ? [{
    host  = "http://mimir-distributor.mimir:8080/api/v1/push"
    key   = "X-Scope-OrgID"
    value = random_uuid.grafana_standard_datasource_header_value.result
  }] : []

  remote_write_config = concat(local.remote_write_config_list, local.default_remote_write_config)
}

data "template_file" "prom_template" {
  count = local.prometheus_enable ? 1 : 0

  template = file("./templates/prometheus-values.yaml")
  vars     = {
    PROMETHEUS_DISK_SIZE              = try(var.observability_config.prometheus.persistence.disk_size != null ? var.observability_config.prometheus.persistence.disk_size : "50Gi", "50Gi")
    PROMETHEUS_RETENTION_SIZE         = try(var.observability_config.prometheus.persistence.retention_size != null ? var.observability_config.prometheus.persistence.retention_size : "20GB", "20GB")
    PROMETHEUS_RETENTION_DURATION     = try(var.observability_config.prometheus.persistence.retention_duration != null ? var.observability_config.prometheus.persistence.retention_duration : "7d", "7d")
    CLUSTER_NAME                      = local.cluster_name
    REMOTE_WRITE_CONFIGS              = jsonencode(local.remote_write_config)
    ALERTS_ENABLED                    = jsonencode(local.cluster_moogsoft_alerts) != "" || jsonencode(local.namespace_teams_webhook) != "" || jsonencode(local.cluster_teams_alerts) != "" || jsonencode(local.google_chat_alerts) != ""  ? true : false
    MOOGSOFT_ALERTS_ENABLED           = local.cluster_moogsoft_alerts == {} ? false : true
    MS_TEAMS_ALERT_ENABLED            = jsonencode(local.namespace_teams_webhook) == "" && jsonencode(local.cluster_teams_alerts) == ""  ? false : true
    MOOGSOFT_ENDPOINT_URL             = jsonencode(local.cluster_moogsoft_alerts)
    MOOGSOFT_ENDPOINT_API_KEY         = var.moogsoft_endpoint_api_key
    MOOGSOFT_USERNAME                 = var.moogsoft_username
    teams_webhook_alerts              = jsonencode(local.cluster_alerts)
    cluster_moogsoft_alerts           = jsonencode(local.cluster_moogsoft_alerts)
    cluster_teams_alerts              = jsonencode(local.cluster_alerts_webhook)
    GOOGLE_CHAT_ALERTS_ENABLED        = local.google_chat_alerts == "" ? false : true
    SLACK_CHAT_ALERTS_ENABLED         = local.cluster_slack_alerts == "" ? false : true
    GOOGLE_CHAT_CONFIGS               = jsonencode(local.google_chat_alerts)
    SLACK_CONFIGS                     = jsonencode(local.cluster_slack_alerts)
    PAGER_DUTY_ALERTS_ENABLED         = local.cluster_pagerduty_alerts == "" ? false : true
    PAGER_DUTY_KEY                    = var.pagerduty_integration_key
    PAGER_DUTY_ENDPOINT_URL           = jsonencode(local.cluster_pagerduty_alerts)
    GRAFANA_HOST                      = local.grafana_enable ? local.grafana_host : ""
  }
}



resource "helm_release" "prometheus" {
  count = local.prometheus_enable ? 1 : 0

  chart            = "kube-prometheus-stack"
  name             = "prometheus"
  namespace        = kubernetes_namespace.monitoring.metadata.0.name
  create_namespace = true
  version          = try(var.observability_config.prometheus.version != null ? var.observability_config.prometheus.version : "60.0.0", "60.0.0")
  timeout          = 1200

  repository = "https://prometheus-community.github.io/helm-charts"

  values = [
    data.template_file.prom_template[count.index].rendered
  ]
}

resource "helm_release" "alerts_teams" {
  count = local.prometheus_enable && local.grafana_enable ? (jsonencode(local.namespace_teams_webhook) == "" && jsonencode(local.cluster_teams_alerts) == "" ? 0 : 1 ) : 0

  repository = "https://prometheus-msteams.github.io/prometheus-msteams"
  chart      = "prometheus-msteams"
  name       = "prometheus-msteams"
  version    = "1.3.0"
  namespace  = helm_release.prometheus[0].namespace

  values = [
    file("./templates/prom-teams-alert-values.yaml")
  ]
}

data "template_file" "cluster-alerts" {
  template = file("./templates/cluster-level-alerts.yaml")
  vars     = {
    cluster_memory_usage_request_underutilisation_threshold = var.cluster_alert_thresholds == null ? 20 : (var.cluster_alert_thresholds.memory_underutilisation != null ? var.cluster_alert_thresholds.memory_underutilisation : 20)
    cluster_cpu_usage_request_underutilisation_threshold = var.cluster_alert_thresholds == null ? 20 : (var.cluster_alert_thresholds.cpu_underutilisation != null ? var.cluster_alert_thresholds.cpu_underutilisation : 20)
    cluster_node_count_max_value = var.node_config.max_count
    cluster_node_count_threshold = var.cluster_alert_thresholds == null ? 80 : (var.cluster_alert_thresholds.node_count != null ? var.cluster_alert_thresholds.node_count : 80)
    cluster_pod_count_threshold = var.cluster_alert_thresholds == null ? 80 : (var.cluster_alert_thresholds.pod_count != null ? var.cluster_alert_thresholds.pod_count: 80)
    cluster_total_cpu_utilization_threshold = var.cluster_alert_thresholds == null ? 80 : (var.cluster_alert_thresholds.cpu_utilisation != null ? var.cluster_alert_thresholds.cpu_utilisation: 80)
    cluster_total_memory_utilization_threshold = var.cluster_alert_thresholds == null ? 20 : (var.cluster_alert_thresholds.memory_utilisation != null ? var.cluster_alert_thresholds.memory_utilisation: 20)
    cluster_disk_utilization_threshold = var.cluster_alert_thresholds == null ? 80 : (var.cluster_alert_thresholds.disk_utilization != null ? var.cluster_alert_thresholds.disk_utilization: 80)
    cluster_name   = local.cluster_name
    cortex_enabled = try(var.observability_config.cortex == null ? false : var.observability_config.cortex.enable, false)
    nginx_5xx_percentage_threshold = var.cluster_alert_thresholds == null ? 5 : (var.cluster_alert_thresholds.nginx_5xx_percentage_threshold != null ? var.cluster_alert_thresholds.nginx_5xx_percentage_threshold: 5)
    cortex_disk_utilization_threshold = var.cluster_alert_thresholds == null ? 80 : (var.cluster_alert_thresholds.cortex_disk_utilization_threshold != null ? var.cluster_alert_thresholds.cortex_disk_utilization_threshold : 80)
    prometheus_disk_utilization_threshold = var.cluster_alert_thresholds == null ? 80 : (var.cluster_alert_thresholds.prometheus_disk_utilization_threshold != null ? var.cluster_alert_thresholds.prometheus_disk_utilization_threshold : 80)
  }
}

resource "kubectl_manifest" "cluster-alerts" {
  count      = local.prometheus_enable ? 1 : 0
  yaml_body  = data.template_file.cluster-alerts.rendered
  depends_on = [helm_release.prometheus]
}