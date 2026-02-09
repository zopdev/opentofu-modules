locals {
  loki_template = local.enable_loki ? templatefile(
    "${path.module}/templates/loki-values.yaml",
    {
      BUCKET_NAME                     = aws_s3_bucket.loki_data[0].id
      AWS_SECRET                      = local.access_secret
      AWS_KEY                         = local.access_key
      app_region                       = var.app_region

      ingester_replicas               = try(var.loki.ingester.replicas, "1")
      ingester_max_memory             = try(var.loki.ingester.max_memory, "null")
      ingester_min_memory             = try(var.loki.ingester.min_memory, "1Gi")
      ingester_max_cpu                = try(var.loki.ingester.max_cpu, "null")
      ingester_min_cpu                = try(var.loki.ingester.min_cpu, "null")
      ingester_autoscaling            = try(var.loki.ingester.autoscaling, "true")
      ingester_max_replicas           = try(var.loki.ingester.max_replicas, "30")
      ingester_min_replicas           = try(var.loki.ingester.min_replicas, "2")
      ingester_cpu_utilization        = try(var.loki.ingester.cpu_utilization, "")
      ingester_memory_utilization     = try(var.loki.ingester.memory_utilization, "")

      distributor_replicas            = try(var.loki.distributor.replicas, "1")
      distributor_max_memory          = try(var.loki.distributor.max_memory, "1Gi")
      distributor_min_memory          = try(var.loki.distributor.min_memory, "512Mi")
      distributor_max_cpu             = try(var.loki.distributor.max_cpu, "1")
      distributor_min_cpu             = try(var.loki.distributor.min_cpu, "250m")
      distributor_autoscaling         = try(var.loki.distributor.autoscaling, "true")
      distributor_max_replicas        = try(var.loki.distributor.max_replicas, "30")
      distributor_min_replicas        = try(var.loki.distributor.min_replicas, "2")
      distributor_memory_utilization  = try(var.loki.distributor.memory_utilization, "")
      distributor_cpu_utilization     = try(var.loki.distributor.cpu_utilization, "")

      querier_replicas                = try(var.loki.querier.replicas, "4")
      querier_max_unavailable         = try(var.loki.querier.max_unavailable, "1")
      querier_min_memory              = try(var.loki.querier.min_memory, "500Mi")
      querier_min_cpu                 = try(var.loki.querier.min_cpu, "100m")
      querier_max_memory              = try(var.loki.querier.max_memory, "null")
      querier_max_cpu                 = try(var.loki.querier.max_cpu, "null")
      querier_autoscaling             = try(var.loki.querier.autoscaling, "true")
      querier_max_replicas            = try(var.loki.querier.max_replicas, "6")
      querier_min_replicas            = try(var.loki.querier.min_replicas, "2")
      querier_memory_utilization      = try(var.loki.querier.memory_utilization, "")
      querier_cpu_utilization         = try(var.loki.querier.cpu_utilization, "")

      queryFrontend_replicas           = try(var.loki.queryFrontend.replicas, "1")
      queryFrontend_min_memory         = try(var.loki.queryFrontend.min_memory, "250Mi")
      queryFrontend_max_memory         = try(var.loki.queryFrontend.max_memory, "null")
      queryFrontend_min_cpu            = try(var.loki.queryFrontend.min_cpu, "null")
      queryFrontend_max_cpu            = try(var.loki.queryFrontend.max_cpu, "null")
      queryFrontend_autoscaling        = try(var.loki.queryFrontend.autoscaling, "true")
      queryFrontend_max_replicas       = try(var.loki.queryFrontend.max_replicas, "6")
      queryFrontend_min_replicas       = try(var.loki.queryFrontend.min_replicas, "1")
      queryFrontend_memory_utilization = try(var.loki.queryFrontend.memory_utilization, "")
      queryFrontend_cpu_utilization    = try(var.loki.queryFrontend.cpu_utilization, "")
    }
  ) : ""
}

resource "aws_s3_bucket" "loki_data" {
  count         = local.enable_loki ? 1 : 0
  bucket        = "${local.cluster_name}-loki-data-${var.observability_suffix}"
  force_destroy = "true"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "loki_data_encryption" {
  count  = local.enable_loki ? 1 : 0
  bucket = aws_s3_bucket.loki_data[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "helm_release" "loki" {
  count      = local.enable_loki ? 1 : 0
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-distributed"
  namespace  = kubernetes_namespace.app_environments["loki"].metadata[0].name
  version    = "0.68.0"

  values = [
    local.loki_template
  ]
}