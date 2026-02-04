locals {
  mimir_template = local.enable_mimir ? templatefile("${path.module}/templates/mimir-values.yaml", {
    data_bucket_name                            = google_storage_bucket.mimir_data[0].id
    cluster_name                                = local.cluster_name
    limits_ingestion_rate                       = try(var.mimir.limits.ingestion_rate != null ? var.mimir.limits.ingestion_rate : "500000", "500000")
    limits_ingestion_burst_size                 = try(var.mimir.limits.ingestion_burst_size != null ? var.mimir.limits.ingestion_burst_size : "1000000", "1000000")
    limits_max_fetched_chunks_per_query         = try(var.mimir.limits.max_fetched_chunks_per_query != null ? var.mimir.limits.max_fetched_chunks_per_query : "5000000", "5000000")
    limits_max_cache_freshness                  = try(var.mimir.limits.max_cache_freshness != null ? var.mimir.limits.max_cache_freshness : "12h", "12h")
    limits_max_outstanding_requests_per_tenant  = try(var.mimir.limits.max_outstanding_requests_per_tenant != null ? var.mimir.limits.max_outstanding_requests_per_tenant : "2000", "2000")
    
    # Compactor configuration
    compactor_replicas                          = try(var.mimir.compactor.replicas != null ? var.mimir.compactor.replicas : "2", "2")
    compactor_persistence_volume_enable         = try(var.mimir.compactor.persistence_volume.enable != null ? var.mimir.compactor.persistence_volume.enable : "true", "true")
    compactor_persistence_volume_size           = try(var.mimir.compactor.persistence_volume.size != null ? var.mimir.compactor.persistence_volume.size : "50Gi", "50Gi")
    compactor_min_cpu                           = try(var.mimir.compactor.min_cpu != null ? var.mimir.compactor.min_cpu : "null", "null")
    compactor_min_memory                        = try(var.mimir.compactor.min_memory != null ? var.mimir.compactor.min_memory : "null", "null")
    compactor_max_cpu                           = try(var.mimir.compactor.max_cpu != null ? var.mimir.compactor.max_cpu : "null", "null")
    compactor_max_memory                        = try(var.mimir.compactor.max_memory != null ? var.mimir.compactor.max_memory : "null", "null")
    
    # Ingester configuration
    ingester_replicas                           = try(var.mimir.ingester.replicas != null ? var.mimir.ingester.replicas : "2", "2")
    ingester_persistence_volume_size            = try(var.mimir.ingester.persistence_volume.size != null ? var.mimir.ingester.persistence_volume.size : "100Gi", "100Gi")
    ingester_min_memory                         = try(var.mimir.ingester.min_memory != null ? var.mimir.ingester.min_memory : "null", "null")
    ingester_min_cpu                            = try(var.mimir.ingester.min_cpu != null ? var.mimir.ingester.min_cpu : "null", "null")
    ingester_max_memory                         = try(var.mimir.ingester.max_memory != null ? var.mimir.ingester.max_memory : "null", "null")
    ingester_max_cpu                            = try(var.mimir.ingester.max_cpu != null ? var.mimir.ingester.max_cpu : "null", "null")
    
    # Querier configuration
    querier_replicas                            = try(var.mimir.querier.replicas != null ? var.mimir.querier.replicas : "2", "2")
    querier_min_memory                          = try(var.mimir.querier.min_memory != null ? var.mimir.querier.min_memory : "null", "null")
    querier_min_cpu                             = try(var.mimir.querier.min_cpu != null ? var.mimir.querier.min_cpu : "null", "null")
    querier_max_memory                          = try(var.mimir.querier.max_memory != null ? var.mimir.querier.max_memory : "null", "null")
    querier_max_cpu                             = try(var.mimir.querier.max_cpu != null ? var.mimir.querier.max_cpu : "null", "null")
    
    # Query Frontend configuration
    query_frontend_replicas                     = try(var.mimir.query_frontend.replicas != null ? var.mimir.query_frontend.replicas : "2", "2")
    
    # Store gateway configuration
    store_gateway_replication_factor            = try(var.mimir.store_gateway.replication_factor != null ? var.mimir.store_gateway.replication_factor : "3", "3")
    store_gateway_replicas                      = try(var.mimir.store_gateway.replicas != null ? var.mimir.store_gateway.replicas : "2", "2")
    store_gateway_persistence_volume_size       = try(var.mimir.store_gateway.persistence_volume.size != null ? var.mimir.store_gateway.persistence_volume.size : "50Gi", "50Gi")
    store_gateway_min_memory                    = try(var.mimir.store_gateway.min_memory != null ? var.mimir.store_gateway.min_memory : "null", "null")
    store_gateway_min_cpu                       = try(var.mimir.store_gateway.min_cpu != null ? var.mimir.store_gateway.min_cpu : "null", "null")
    store_gateway_max_memory                    = try(var.mimir.store_gateway.max_memory != null ? var.mimir.store_gateway.max_memory : "null", "null")
    store_gateway_max_cpu                       = try(var.mimir.store_gateway.max_cpu != null ? var.mimir.store_gateway.max_cpu : "null", "null")
    
    # Distributor configuration
    distributor_replicas                        = try(var.mimir.distributor.replicas != null ? var.mimir.distributor.replicas : "2", "2")
    distributor_min_memory                      = try(var.mimir.distributor.min_memory != null ? var.mimir.distributor.min_memory : "null", "null")
    distributor_min_cpu                         = try(var.mimir.distributor.min_cpu != null ? var.mimir.distributor.min_cpu : "null", "null")
    distributor_max_memory                      = try(var.mimir.distributor.max_memory != null ? var.mimir.distributor.max_memory : "null", "null")
    distributor_max_cpu                         = try(var.mimir.distributor.max_cpu != null ? var.mimir.distributor.max_cpu : "null", "null")
    
    # Cache configuration
    chunks_cache_enabled                        = try(var.mimir.caches.chunks.enabled != null ? var.mimir.caches.chunks.enabled : "true", "true")
    chunks_cache_replicas                       = try(var.mimir.caches.chunks.replicas != null ? var.mimir.caches.chunks.replicas : 1, 1)
    chunks_cache_max_item_memory                = try(var.mimir.caches.chunks.max_item_memory != null ? var.mimir.caches.chunks.max_item_memory : 1, 1)
    chunks_cache_max_item_memory_mb             = try(var.mimir.caches.chunks.max_item_memory != null ? var.mimir.caches.chunks.max_item_memory * 1024 * 1024 : 1048576, 1048576)
    chunks_cache_connection_limit               = try(var.mimir.caches.chunks.connection_limit != null ? var.mimir.caches.chunks.connection_limit : 16384, 16384)
    
    index_cache_enabled                         = try(var.mimir.caches.index.enabled != null ? var.mimir.caches.index.enabled : "true", "true")
    index_cache_replicas                        = try(var.mimir.caches.index.replicas != null ? var.mimir.caches.index.replicas : 1, 1)
    index_cache_max_item_memory                 = try(var.mimir.caches.index.max_item_memory != null ? var.mimir.caches.index.max_item_memory : 5, 5)
    index_cache_max_item_memory_mb              = try(var.mimir.caches.index.max_item_memory != null ? var.mimir.caches.index.max_item_memory * 1024 * 1024 : 5242880, 5242880)
    index_cache_connection_limit                = try(var.mimir.caches.index.connection_limit != null ? var.mimir.caches.index.connection_limit : 16384, 16384)
    
    metadata_cache_enabled                      = try(var.mimir.caches.metadata.enabled != null ? var.mimir.caches.metadata.enabled : "true", "true")
    metadata_cache_replicas                     = try(var.mimir.caches.metadata.replicas != null ? var.mimir.caches.metadata.replicas : 2, 2)
    metadata_cache_max_item_memory              = try(var.mimir.caches.metadata.max_item_memory != null ? var.mimir.caches.metadata.max_item_memory : 1, 1)
    metadata_cache_max_item_memory_mb           = try(var.mimir.caches.metadata.max_item_memory != null ? var.mimir.caches.metadata.max_item_memory * 1024 * 1024 : 1048576, 1048576)
    metadata_cache_connection_limit             = try(var.mimir.caches.metadata.connection_limit != null ? var.mimir.caches.metadata.connection_limit : 16384, 16384)
    
    # Authentication
    mimir_basic_auth_username                    = random_password.mimir_basic_auth_username[0].result
    mimir_basic_auth_password                    = random_password.mimir_basic_auth_password[0].result
  }) : null
}

resource "google_storage_bucket" "mimir_data" {
  count = local.enable_mimir ? 1 : 0
  name          = "${local.cluster_name}-mimir-block-data-${var.observability_suffix}"
  location      = var.app_region
  project       = var.project_id
  force_destroy = true
  labels        = var.labels
}

resource "google_service_account" "mimir_svc_acc" {
  count = local.enable_mimir ? 1 : 0
  project    = var.project_id
  account_id = "${var.service_account_name_prefix}-mimir-data"
}

resource "google_service_account_key" "mimir_svc_acc_key" {
  count = local.enable_mimir ? 1 : 0
  service_account_id = google_service_account.mimir_svc_acc[0].name
}

resource "google_storage_bucket_iam_member" "mimir_svc_acc" {
  count = local.enable_mimir ? 1 : 0
  bucket      = google_storage_bucket.mimir_data[0].name
  role        = "roles/storage.objectAdmin"
  member      = "serviceAccount:${google_service_account.mimir_svc_acc[0].email}"
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
  special = false
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

resource "kubernetes_secret" "mimir-google-credentials" {
  count = local.enable_mimir ? 1 : 0
  metadata {
    name      = "${local.cluster_name}-mimir-google-credentials"
    namespace = kubernetes_namespace.app_environments["mimir"].metadata[0].name
    labels    = { app = var.app_name }
    annotations = {
      "kubernetes.io/service-account.name" = "${local.cluster_name}-mimir-google-credentials"
    }
  }

  data = {
    "gcs.json" = base64decode(google_service_account_key.mimir_svc_acc_key[0].private_key)
  }

  type = "Opaque"
}

resource "helm_release" "mimir" {
  count = local.enable_mimir ? 1 : 0
  name       = "mimir"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "mimir-distributed"
  namespace  = kubernetes_namespace.app_environments["mimir"].metadata[0].name
  version    = "5.1.3"
  values = [
    local.mimir_template
  ]

  depends_on = [
    kubernetes_secret.mimir-google-credentials,
    kubernetes_secret.mimir-basic-auth,
  ]
}
