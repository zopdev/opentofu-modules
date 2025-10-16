namespace = "monitoring"

locals {
    ## this is otel remote write configs
    remote_write_config_list = try([
        for remote in var.observability_config.otel.remote_write : {
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

data "template_file" "otel_template" {
    count = local.enable_otel ? 1 : 0
    template = file("./templates/otel-collector-values.yaml")
    vars = {
        REMOTE_WRITE_CONFIGS   = jsonencode(local.remote_write_config)
        SCRAPE_INTERVAL        = try(var.observability_config.otel.scrape_interval != null ? var.observability_config.otel.scrape_interval : "30s", "30s")
        BATCH_SIZE             = try(var.observability_config.otel.batch_size != null ? var.observability_config.otel.batch_size : "10000", "10000")
        TIMEOUT                = try(var.observability_config.otel.timeout != null ? var.observability_config.otel.timeout : "10s", "10s")
        SPIKE_LIMIT_PERCENTAGE = try(var.observability_config.otel.spike_limit_percentage != null ? var.observability_config.otel.spike_limit_percentage : "20", "20")
        LIMIT_PERCENTAGE       = try(var.observability_config.otel.limit_percentage != null ? var.observability_config.otel.limit_percentage : "80", "80")
        CHECK_INTERVAL         = try(var.observability_config.otel.check_interval != null ? var.observability_config.otel.check_interval : "1s", "1s")
        QUEUE_SIZE             = try(var.observability_config.otel.queue_size != null ? var.observability_config.otel.queue_size : "5000", "5000")
        NUM_CONSUMERS          = try(var.observability_config.otel.num_consumers != null ? var.observability_config.otel.num_consumers : "10", "10")
        INITIAL_INTERVAL       = try(var.observability_config.otel.initial_interval != null ? var.observability_config.otel.initial_interval : "5s", "5s")
        MAX_INTERVAL           = try(var.observability_config.otel.max_interval != null ? var.observability_config.otel.max_interval : "30s", "30s")
        MAX_ELAPSED_TIME       = try(var.observability_config.otel.max_elapsed_time != null ? var.observability_config.otel.max_elapsed_time : "300s", "300s")
    }
}

resource "helm_release" "otel_collector" {
    count = local.enable_otel ? 1 : 0

    chart            = "opentelemetry-collector"
    name             = "otel-collector"
    namespace        = kubernetes_namespace.monitoring.metadata.0.name
    create_namespace = true
    version          = try(var.observability_config.otel.version != null ? var.observability_config.otel.version : "0.136.1", "0.136.1") 
    timeout          = 1200

    repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"

    values = [
        data.template_file.otel_template[count.index].rendered
    ]

    depends_on = [helm_release.mimir]
}