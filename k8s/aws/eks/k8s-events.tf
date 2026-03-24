locals {
  # Kubernetes event exporter local configs
  enable_k8s_event_exporter = try(var.observability_config.kubernetes_event_exporter.enable != null ? var.observability_config.kubernetes_event_exporter.enable : false, false)
  loki_receivers = try([
    for receiver in var.observability_config.kubernetes_event_exporter.loki_receivers : {
      name         = receiver.name
      url          = receiver.url
      header_key   = receiver.header != null ? receiver.header.key : ""
      header_value = receiver.header != null ? receiver.header.value : ""
      cluster_id   = receiver.cluster_id != null ? receiver.cluster_id : ""
    }
  ], [])

  webhook_receivers = try([
    for receiver in var.observability_config.kubernetes_event_exporter.webhook_receivers : {
      name         = receiver.name
      type         = receiver.type
      url          = receiver.url
      header_key   = receiver.header != null ? receiver.header.key : ""
      header_value = receiver.header != null ? receiver.header.value : ""
    }
  ], [])


  observability_loki_recievers = local.enable_loki ?  [{
    name         = local.cluster_name
    url          = "http://loki-distributor.loki:3100/loki/api/v1/push"
    header_key   = "X-Scope-OrgID"
    header_value = random_uuid.grafana_standard_datasource_header_value.result
    cluster_id   = ""
  }] : []

  all_loki_receivers = concat(local.loki_receivers,local.observability_loki_recievers)
}

data "template_file" "k8s_event_exporter" {
  count = local.enable_k8s_event_exporter || local.enable_loki ? 1 : 0

  template = file("./templates/event-exporter-values.yaml")
  vars     = {
    CLUSTER_NAME             = local.cluster_name
    LOG_LEVEL                = try(var.observability_config.kubernetes_event_exporter.log_level != null ? var.observability_config.kubernetes_event_exporter.log_level : "error" , "error")
    MAX_EVENT_AGE_SECONDS    = try(var.observability_config.kubernetes_event_exporter.max_event_age_second != null ? var.observability_config.kubernetes_event_exporter.max_event_age_second : "150" , "150")
    LOKI_RECEIVER_CONFIGS    = jsonencode(local.all_loki_receivers)
    WEBHOOK_RECEIVER_CONFIGS = jsonencode(local.webhook_receivers)
    LIMIT_CPU                = try(var.observability_config.kubernetes_event_exporter.resource.limit_cpu != null ? var.observability_config.kubernetes_event_exporter.resource.limit_cpu : "400m", "400m")
    LIMIT_MEMORY             = try(var.observability_config.kubernetes_event_exporter.resource.limit_memory != null ? var.observability_config.kubernetes_event_exporter.resource.limit_memory : "250Mi", "250Mi")
    REQUEST_CPU              = try(var.observability_config.kubernetes_event_exporter.resource.request_cpu != null ? var.observability_config.kubernetes_event_exporter.resource.request_cpu : "100m", "100m")
    REQUEST_MEMORY           = try(var.observability_config.kubernetes_event_exporter.resource.request_memory != null ? var.observability_config.kubernetes_event_exporter.resource.request_memory : "100Mi", "100Mi")
  }
}

resource "helm_release" "kubernetes_event_exporter" {
  count = local.enable_k8s_event_exporter || local.enable_loki ? 1 : 0

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kubernetes-event-exporter"
  name       = "kubernetes-event-exporter"
  version    = "2.10.1"
  namespace  = helm_release.prometheus[0].namespace

  values = [
    data.template_file.k8s_event_exporter[count.index].rendered
  ]
}