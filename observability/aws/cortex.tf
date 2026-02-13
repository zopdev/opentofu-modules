locals {
  cortex_template = local.enable_cortex ? templatefile(
    "${path.module}/templates/cortex-values.yaml",
    {
      BUCKET_NAME                           = aws_s3_bucket.cortex_data[0].id
      AWS_SECRET                             = var.access_secret
      AWS_KEY                                = var.access_key
      cluster_name                            = local.cluster_name
      app_region                              = var.app_region

      limits_ingestion_rate                  = try(var.cortex.limits.ingestion_rate, "250000")
      limits_ingestion_burst_size            = try(var.cortex.limits.ingestion_burst_size, "500000")
      limits_max_series_per_metric           = try(var.cortex.limits.max_series_per_metric, "0")
      limits_max_series_per_user             = try(var.cortex.limits.max_series_per_user, "0")
      limits_max_fetched_chunks_per_query    = try(var.cortex.limits.max_fetched_chunks_per_query, "3000000")
      query_range_memcached_client_timeout   = try(var.cortex.query_range.memcached_client_timeout, "30s")

      compactor_enable                       = try(var.cortex.compactor.enable, "true")
      compactor_replicas                     = try(var.cortex.compactor.replicas, "1")
      compactor_persistence_volume_enable    = try(var.cortex.compactor.persistence_volume.enable, "true")
      compactor_persistence_volume_size      = try(var.cortex.compactor.persistence_volume.size, "20Gi")
      compactor_min_cpu                       = try(var.cortex.compactor.min_cpu, "null")
      compactor_min_memory                    = try(var.cortex.compactor.min_memory, "null")
      compactor_max_cpu                       = try(var.cortex.compactor.max_cpu, "null")
      compactor_max_memory                    = try(var.cortex.compactor.max_memory, "null")

      ingester_replicas                      = try(var.cortex.ingester.replicas, "1")
      ingester_persistence_volume_size       = try(var.cortex.ingester.persistence_volume.size, "20Gi")
      ingester_min_memory                     = try(var.cortex.ingester.min_memory, "null")
      ingester_min_cpu                        = try(var.cortex.ingester.min_cpu, "null")
      ingester_max_memory                     = try(var.cortex.ingester.max_memory, "null")
      ingester_max_cpu                        = try(var.cortex.ingester.max_cpu, "null")
      ingester_autoscaling                    = try(var.cortex.ingester.autoscaling, "true")
      ingester_max_replicas                   = try(var.cortex.ingester.max_replicas, "100")
      ingester_min_replicas                   = try(var.cortex.ingester.min_replicas, "2")
      ingester_memory_utilization             = try(var.cortex.ingester.memory_utilization, "")

      querier_replicas                        = try(var.cortex.querier.replicas, "1")
      querier_min_memory                       = try(var.cortex.querier.min_memory, "null")
      querier_min_cpu                          = try(var.cortex.querier.min_cpu, "null")
      querier_max_memory                       = try(var.cortex.querier.max_memory, "null")
      querier_max_cpu                          = try(var.cortex.querier.max_cpu, "null")
      querier_autoscaling                       = try(var.cortex.querier.autoscaling, "true")
      querier_max_replicas                       = try(var.cortex.querier.max_replicas, "20")
      querier_min_replicas                       = try(var.cortex.querier.min_replicas, "2")
      querier_memory_utilization                 = try(var.cortex.querier.memory_utilization, "")
      querier_cpu_utilization                     = try(var.cortex.querier.cpu_utilization, "")

      query_frontend_replicas                    = try(var.cortex.query_frontend.replicas, "4")
      query_frontend_enable                      = try(var.cortex.query_frontend.enable, "true")

      store_gateway_replication_factor           = try(var.cortex.store_gateway.replication_factor, "3")
      store_gateway_replicas                      = try(var.cortex.store_gateway.replicas, "1")
      store_gateway_persistence_volume_size       = try(var.cortex.store_gateway.persistence_volume.size, "500Gi")
      store_gateway_min_memory                    = try(var.cortex.store_gateway.min_memory, "null")
      store_gateway_min_cpu                        = try(var.cortex.store_gateway.min_cpu, "null")
      store_gateway_max_memory                     = try(var.cortex.store_gateway.max_memory, "null")
      store_gateway_max_cpu                        = try(var.cortex.store_gateway.max_cpu, "null")

      memcached_frontend_enable                   = try(var.cortex.memcached_frontend.enable, "true")
      memcached_frontend_min_memory               = try(var.cortex.memcached_frontend.min_memory, "null")
      memcached_frontend_min_cpu                  = try(var.cortex.memcached_frontend.min_cpu, "null")
      memcached_frontend_max_memory               = try(var.cortex.memcached_frontend.max_memory, "null")
      memcached_frontend_max_cpu                  = try(var.cortex.memcached_frontend.max_cpu, "null")

      memcached_blocks_index_enable               = try(var.cortex.memcached_blocks_index.enable, "true")
      memcached_blocks_index_min_cpu              = try(var.cortex.memcached_blocks_index.min_cpu, "null")
      memcached_blocks_index_min_memory           = try(var.cortex.memcached_blocks_index.min_memory, "null")
      memcached_blocks_index_max_cpu              = try(var.cortex.memcached_blocks_index.max_cpu, "null")
      memcached_blocks_index_max_memory           = try(var.cortex.memcached_blocks_index.max_memory, "null")

      memcached_blocks_enable                     = try(var.cortex.memcached_blocks.enable, "true")
      memcached_blocks_min_memory                 = try(var.cortex.memcached_blocks.min_memory, "null")
      memcached_blocks_min_cpu                    = try(var.cortex.memcached_blocks.min_cpu, "null")
      memcached_blocks_max_memory                 = try(var.cortex.memcached_blocks.max_memory, "null")
      memcached_blocks_max_cpu                     = try(var.cortex.memcached_blocks.max_cpu, "null")

      memcached_blocks_metadata_enable            = try(var.cortex.memcached_blocks_metadata.enable, "true")
      memcached_blocks_metadata_min_memory        = try(var.cortex.memcached_blocks_metadata.min_memory, "null")
      memcached_blocks_metadata_min_cpu           = try(var.cortex.memcached_blocks_metadata.min_cpu, "null")
      memcached_blocks_metadata_max_memory        = try(var.cortex.memcached_blocks_metadata.max_memory, "null")
      memcached_blocks_metadata_max_cpu           = try(var.cortex.memcached_blocks_metadata.max_cpu, "null")

      distributor_replicas                        = try(var.cortex.distributor.replicas, "1")
      distributor_min_memory                       = try(var.cortex.distributor.min_memory, "null")
      distributor_min_cpu                          = try(var.cortex.distributor.min_cpu, "null")
      distributor_max_memory                       = try(var.cortex.distributor.max_memory, "null")
      distributor_max_cpu                          = try(var.cortex.distributor.max_cpu, "null")
      distributor_autoscaling                      = try(var.cortex.distributor.autoscaling, "true")
      distributor_max_replicas                     = try(var.cortex.distributor.max_replicas, "30")
      distributor_min_replicas                     = try(var.cortex.distributor.min_replicas, "2")
      distributor_memory_utilization               = try(var.cortex.distributor.memory_utilization, "")
      distributor_cpu_utilization                  = try(var.cortex.distributor.cpu_utilization, "")
    }
  ) : ""
}

resource "aws_s3_bucket" "cortex_data" {
  count         = local.enable_cortex ? 1 : 0
  bucket        = "${local.cluster_name}-cortex-data-${var.observability_suffix}"
  force_destroy = false
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cortex_encryption" {
  count  = local.enable_cortex ? 1 : 0
  bucket = aws_s3_bucket.cortex_data[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "cortex_public_access_block" {
  count  = local.enable_cortex ? 1 : 0
  bucket = aws_s3_bucket.cortex_data[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



resource "aws_s3_bucket_server_side_encryption_configuration" "cortex_data_encryption" {
  count  = local.enable_cortex ? 1 : 0
  bucket = aws_s3_bucket.cortex_data[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "kubernetes_secret" "cortex-aws-credentials" {
  count         = local.enable_cortex ? 1 : 0
  metadata {
    name        = "${local.cluster_name}-cortex-aws-credentials"
    namespace   = kubernetes_namespace.app_environments["cortex"].metadata[0].name
    labels      = { app = var.app_name }
    annotations = {
      "kubernetes.io/service-account.name" = "${local.cluster_name}-cortex-aws-credentials"
    }
  }

  data = {
    "credentials" = "[default]\naws_access_key_id=${var.access_key}\naws_secret_access_key=${var.access_secret}"
  }
  type = "Opaque"

}

resource "helm_release" "cortex" {
  count      = local.enable_cortex ? 1 : 0
  name       = "cortex"
  repository = "https://cortexproject.github.io/cortex-helm-chart"
  chart      = "cortex"
  namespace  = kubernetes_namespace.app_environments["cortex"].metadata[0].name
  version    = "1.7.0"

  values = [
    local.cortex_template
  ]
}
