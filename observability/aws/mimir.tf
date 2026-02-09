locals {
  mimir_template = local.enable_mimir ? templatefile(
    "${path.module}/templates/mimir-values.yaml",
    {
      BUCKET_NAME                                = aws_s3_bucket.mimir_data[0].id
      cluster_name                               = local.cluster_name
      app_region                                 = var.app_region
      AWS_SECRET                                 = var.access_secret
      AWS_KEY                                    = var.access_key
      limits_ingestion_rate                      = try(var.mimir.limits.ingestion_rate, "250000")
      limits_ingestion_burst_size                = try(var.mimir.limits.ingestion_burst_size, "500000")
      limits_max_fetched_chunks_per_query        = try(var.mimir.limits.max_fetched_chunks_per_query, "3000000")
      limits_max_cache_freshness                 = try(var.mimir.limits.max_cache_freshness, "24h")
      limits_max_outstanding_requests_per_tenant = try(var.mimir.limits.max_outstanding_requests_per_tenant, "1000")
      compactor_replicas                         = try(var.mimir.compactor.replicas, "1")
      compactor_persistence_volume_enable        = try(var.mimir.compactor.persistence_volume.enable, "true")
      compactor_persistence_volume_size          = try(var.mimir.compactor.persistence_volume.size, "20Gi")
      compactor_min_cpu                          = try(var.mimir.compactor.min_cpu, "null")
      compactor_min_memory                       = try(var.mimir.compactor.min_memory, "null")
      compactor_max_cpu                          = try(var.mimir.compactor.max_cpu, "null")
      compactor_max_memory                       = try(var.mimir.compactor.max_memory, "null")
      ingester_replicas                          = try(var.mimir.ingester.replicas, "2")
      ingester_persistence_volume_size           = try(var.mimir.ingester.persistence_volume.size, "20Gi")
      ingester_min_memory                        = try(var.mimir.ingester.min_memory, "null")
      ingester_min_cpu                           = try(var.mimir.ingester.min_cpu, "null")
      ingester_max_memory                        = try(var.mimir.ingester.max_memory, "null")
      ingester_max_cpu                           = try(var.mimir.ingester.max_cpu, "null")
      querier_replicas                           = try(var.mimir.querier.replicas, "3")
      querier_min_memory                         = try(var.mimir.querier.min_memory, "null")
      querier_min_cpu                            = try(var.mimir.querier.min_cpu, "null")
      querier_max_memory                         = try(var.mimir.querier.max_memory, "null")
      querier_max_cpu                            = try(var.mimir.querier.max_cpu, "null")
      query_frontend_replicas                    = try(var.mimir.query_frontend.replicas, "1")
      store_gateway_replication_factor           = try(var.mimir.store_gateway.replication_factor, "3")
      store_gateway_replicas                     = try(var.mimir.store_gateway.replicas, "1")
      store_gateway_persistence_volume_size      = try(var.mimir.store_gateway.persistence_volume.size, "500Gi")
      store_gateway_min_memory                   = try(var.mimir.store_gateway.min_memory, "null")
      store_gateway_min_cpu                      = try(var.mimir.store_gateway.min_cpu, "null")
      store_gateway_max_memory                   = try(var.mimir.store_gateway.max_memory, "null")
      store_gateway_max_cpu                      = try(var.mimir.store_gateway.max_cpu, "null")
      distributor_replicas                       = try(var.mimir.distributor.replicas, "1")
      distributor_min_memory                     = try(var.mimir.distributor.min_memory, "null")
      distributor_min_cpu                        = try(var.mimir.distributor.min_cpu, "null")
      distributor_max_memory                     = try(var.mimir.distributor.max_memory, "null")
      distributor_max_cpu                        = try(var.mimir.distributor.max_cpu, "null")
      mimir_basic_auth_username                  = random_password.mimir_basic_auth_username[0].result
      mimir_basic_auth_password                  = random_password.mimir_basic_auth_password[0].result
    }
  ) : null
}

resource "aws_s3_bucket" "mimir_data" {
  count = local.enable_mimir ? 1 : 0
  bucket        = "${local.cluster_name}-mimir-data-${var.observability_suffix}"
  force_destroy = "true"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mimir_data_encryption" {
  count  = local.enable_mimir ? 1 : 0
  bucket = aws_s3_bucket.mimir_data[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "random_password" "mimir_basic_auth_username" {
  count   = local.enable_mimir ? 1 : 0
  length  = 16
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "random_password" "mimir_basic_auth_password" {
  count   = local.enable_mimir ? 1 : 0
  length  = 32
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "kubernetes_secret" "mimir-basic-auth" {
  count = local.enable_mimir ? 1 : 0
  metadata {
    name      = "mimir-basic-auth"
    namespace = kubernetes_namespace.app_environments["mimir"].metadata[0].name
    labels    = { app = var.app_name }
  }

  data = {
    # NGINX Ingress Controller expects the key to be 'auth' for basic auth
    auth = "${random_password.mimir_basic_auth_username[0].result}:${bcrypt(random_password.mimir_basic_auth_password[0].result)}"
  }

  type = "Opaque"
}

resource "kubernetes_secret" "mimir-aws-credentials" {
  count = local.enable_mimir ? 1 : 0
  metadata {
    name        = "${local.cluster_name}-mimir-aws-credentials"
    namespace   = kubernetes_namespace.app_environments["mimir"].metadata[0].name
    labels      = { app = var.app_name }
    annotations = {
      "kubernetes.io/service-account.name" = "${local.cluster_name}-mimir-aws-credentials"
    }
  }

  data = {
    "credentials" = "[default]\naws_access_key_id=${var.access_key}\naws_secret_access_key=${var.access_secret}"
  }
  type = "Opaque"

}

resource "helm_release" "mimir" {
  count      = local.enable_mimir ? 1 : 0
  name       = "mimir"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "mimir-distributed"
  namespace  = kubernetes_namespace.app_environments["mimir"].metadata[0].name
  version    = "5.1.3"
  values = [
    local.mimir_template
  ]

  depends_on = [
    kubernetes_secret.mimir-basic-auth
  ]
}