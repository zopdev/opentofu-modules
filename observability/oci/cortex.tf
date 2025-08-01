resource "oci_objectstorage_bucket" "cortex_data" {
    count           = local.enable_cortex ? 1 : 0
    compartment_id  = var.provider_id
    name            = "${local.cluster_name}-cortex-data-${var.observability_suffix}"
    namespace       = var.tenancy_namespace
}

resource "null_resource" "cleanup_cortex_bucket" {
  count = local.enable_cortex ? 1 : 0

  triggers = {
    bucket_name = oci_objectstorage_bucket.cortex_data[0].name
    namespace   = var.tenancy_namespace
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      echo "Cleaning up bucket: ${self.triggers.bucket_name}"
      objects=$(oci os object list --namespace-name ${self.triggers.namespace} --bucket-name ${self.triggers.bucket_name} --all --query 'data[*].name' --output json)

      echo "$objects" | jq -c '.[]' | while read name; do
        name=$(echo "$name" | tr -d '"')
        echo "Deleting: $name"
        oci os object delete --namespace-name ${self.triggers.namespace} --bucket-name ${self.triggers.bucket_name} --object-name "$name" --force
      done

      echo "Bucket cleanup completed."
    EOT
  }

  depends_on = [oci_objectstorage_bucket.cortex_data]
}



resource "kubernetes_secret" "cortex-oci-credentials" {
  count         = local.enable_cortex ? 1 : 0
  metadata {
    name        = "${local.cluster_name}-cortex-oci-credentials"
    namespace   = kubernetes_namespace.app_environments["cortex"].metadata[0].name
    labels      = { app = var.app_name }
    annotations = {
      "kubernetes.io/service-account.name" = "${local.cluster_name}-cortex-oci-credentials"
    }
  }

  data = {
    "credentials" = "[default]\naws_access_key_id=${var.access_key}\naws_secret_access_key=${var.access_secret}"
  }
  type = "Opaque"

}

data "template_file" "cortex_template"{
  count    = local.enable_cortex ? 1 : 0
  template = file("${path.module}/templates/cortex-values.yaml")
  vars = {
    "BUCKET_NAME"                         = oci_objectstorage_bucket.cortex_data[0].name
    "OCI_SECRET"                          = var.access_secret
    "OCI_KEY"                             = var.access_key
    cluster_name                          = local.cluster_name
    app_region                            = var.app_region
    tenancy_namespace                     = var.tenancy_namespace
    limits_ingestion_rate                 = try(var.cortex.limits.ingestion_rate != null ? var.cortex.limits.ingestion_rate : "250000", "250000")
    limits_ingestion_burst_size           = try(var.cortex.limits.ingestion_burst_size != null ? var.cortex.limits.ingestion_burst_size : "500000", "500000")
    limits_max_series_per_metric          = try(var.cortex.limits.max_series_per_metric != null ? var.cortex.limits.max_series_per_metric : "0", "0")
    limits_max_series_per_user            = try(var.cortex.limits.max_series_per_user != null ? var.cortex.limits.max_series_per_user : "0", "0")
    limits_max_fetched_chunks_per_query   = try(var.cortex.limits.max_fetched_chunks_per_query != null ? var.cortex.limits.max_fetched_chunks_per_query : "3000000", "3000000")
    query_range_memcached_client_timeout  = try(var.cortex.query_range.memcached_client_timeout != null ? var.cortex.query_range.memcached_client_timeout : "30s", "30s")
    compactor_enable                      = try(var.cortex.compactor.enable != null ? var.cortex.compactor.enable : "true", "true")
    compactor_replicas                    = try(var.cortex.compactor.replicas != null ? var.cortex.compactor.replicas : "1", "1")
    compactor_persistence_volume_enable   = try(var.cortex.compactor.persistence_volume.enable != null ? var.cortex.compactor.persistence_volume.enable : "true", "true")
    compactor_persistence_volume_size     = try(var.cortex.compactor.persistence_volume.size != null ? var.cortex.compactor.persistence_volume.size : "20Gi", "20Gi")
    compactor_min_cpu                     = try(var.cortex.compactor.min_cpu != null ? var.cortex.compactor.min_cpu : "null", "null")
    compactor_min_memory                  = try(var.cortex.compactor.min_memory != null ? var.cortex.compactor.min_memory : "null", "null")
    compactor_max_cpu                     = try(var.cortex.compactor.max_cpu != null ? var.cortex.compactor.max_cpu : "null", "null")
    compactor_max_memory                  = try(var.cortex.compactor.max_memory != null ? var.cortex.compactor.max_memory : "null", "null")
    ingester_replicas                     = try(var.cortex.ingester.replicas != null ? var.cortex.ingester.replicas : "1", "1")
    ingester_persistence_volume_size      = try(var.cortex.ingester.persistence_volume.size != null ? var.cortex.ingester.persistence_volume.size : "20Gi", "20Gi")
    ingester_min_memory                   = try(var.cortex.ingester.min_memory != null ? var.cortex.ingester.min_memory : "null", "null")
    ingester_min_cpu                      = try(var.cortex.ingester.min_cpu != null ? var.cortex.ingester.min_cpu : "null", "null")
    ingester_max_memory                   = try(var.cortex.ingester.max_memory != null ? var.cortex.ingester.max_memory : "null", "null")
    ingester_max_cpu                      = try(var.cortex.ingester.max_cpu != null ? var.cortex.ingester.max_cpu : "null", "null")
    ingester_autoscaling                  = try(var.cortex.ingester.autoscaling != null ? var.cortex.ingester.autoscaling : "true", "true")
    ingester_max_replicas                 = try(var.cortex.ingester.max_replicas != null ? var.cortex.ingester.max_replicas : "100", "100")
    ingester_min_replicas                 = try(var.cortex.ingester.min_replicas != null ? var.cortex.ingester.min_replicas : "2", "2")
    ingester_memory_utilization           = try(var.cortex.ingester.memory_utilization != null ? var.cortex.ingester.memory_utilization : "", "")
    querier_replicas                      = try(var.cortex.querier.replicas != null ? var.cortex.querier.replicas : "1", "1")
    querier_min_memory                    = try(var.cortex.querier.min_memory != null ? var.cortex.querier.min_memory : "null", "null")
    querier_min_cpu                       = try(var.cortex.querier.min_cpu != null ? var.cortex.querier.min_cpu : "null", "null")
    querier_max_memory                    = try(var.cortex.querier.max_memory != null ? var.cortex.querier.max_memory : "null", "null")
    querier_max_cpu                       = try(var.cortex.querier.max_cpu != null ? var.cortex.querier.max_cpu : "null", "null")
    querier_autoscaling                   = try(var.cortex.querier.autoscaling != null ? var.cortex.querier.autoscaling : "true", "true")
    querier_max_replicas                  = try(var.cortex.querier.max_replicas != null ? var.cortex.querier.max_replicas : "20", "20")
    querier_min_replicas                  = try(var.cortex.querier.min_replicas != null ? var.cortex.querier.min_replicas : "2", "2")
    querier_memory_utilization            = try(var.cortex.querier.memory_utilization != null ? var.cortex.querier.memory_utilization : "", "")
    querier_cpu_utilization               = try(var.cortex.querier.cpu_utilization != null ? var.cortex.querier.cpu_utilization : "", "")
    query_frontend_replicas               = try(var.cortex.query_frontend.replicas != null ? var.cortex.query_frontend.replicas : "4", "4")
    query_frontend_enable                 = try(var.cortex.query_frontend.enable != null ? var.cortex.query_frontend.enable : "true", "true")
    store_gateway_replication_factor      = try(var.cortex.store_gateway.replication_factor != null ? var.cortex.store_gateway.replication_factor : "3", "3")
    store_gateway_replicas                = try(var.cortex.store_gateway.replicas != null ? var.cortex.store_gateway.replicas : "1", "1")
    store_gateway_persistence_volume_size = try(var.cortex.store_gateway.persistence_volume.size != null ? var.cortex.store_gateway.persistence_volume.size : "500Gi", "500Gi")
    store_gateway_min_memory              = try(var.cortex.store_gateway.min_memory != null ? var.cortex.store_gateway.min_memory : "null", "null")
    store_gateway_min_cpu                 = try(var.cortex.store_gateway.min_cpu != null ? var.cortex.store_gateway.min_cpu : "null", "null")
    store_gateway_max_memory              = try(var.cortex.store_gateway.max_memory != null ? var.cortex.store_gateway.max_memory : "null", "null")
    store_gateway_max_cpu                 = try(var.cortex.store_gateway.max_cpu != null ? var.cortex.store_gateway.max_cpu : "null", "null")
    memcached_frontend_enable             = try(var.cortex.memcached_frontend.enable != null ? var.cortex.memcached_frontend.enable : "true", "true")
    memcached_frontend_min_memory         = try(var.cortex.memcached_frontend.min_memory != null ? var.cortex.memcached_frontend.min_memory : "null", "null")
    memcached_frontend_min_cpu            = try(var.cortex.memcached_frontend.min_cpu != null ? var.cortex.memcached_frontend.min_cpu : "null", "null")
    memcached_frontend_max_memory         = try(var.cortex.memcached_frontend.max_memory != null ? var.cortex.memcached_frontend.max_memory : "null", "null")
    memcached_frontend_max_cpu            = try(var.cortex.memcached_frontend.max_cpu != null ? var.cortex.memcached_frontend.max_cpu : "null", "null")
    memcached_blocks_index_enable         = try(var.cortex.memcached_blocks_index.enable != null ? var.cortex.memcached_blocks_index.enable : "true", "true")
    memcached_blocks_index_min_cpu        = try(var.cortex.memcached_blocks_index.min_cpu != null ? var.cortex.memcached_blocks_index.min_cpu : "null", "null")
    memcached_blocks_index_min_memory     = try(var.cortex.memcached_blocks_index.min_memory != null ? var.cortex.memcached_blocks_index.min_memory : "null", "null")
    memcached_blocks_index_max_cpu        = try(var.cortex.memcached_blocks_index.max_cpu != null ? var.cortex.memcached_blocks_index.max_cpu : "null", "null")
    memcached_blocks_index_max_memory     = try(var.cortex.memcached_blocks_index.max_memory != null ? var.cortex.memcached_blocks_index.max_memory : "null", "null")
    memcached_blocks_enable               = try(var.cortex.memcached_blocks.enable != null ? var.cortex.memcached_blocks.enable : "true", "true")
    memcached_blocks_min_memory           = try(var.cortex.memcached_blocks.min_memory != null ? var.cortex.memcached_blocks.min_memory : "null", "null")
    memcached_blocks_min_cpu              = try(var.cortex.memcached_blocks.min_cpu != null ? var.cortex.memcached_blocks.min_cpu : "null", "null")
    memcached_blocks_max_memory           = try(var.cortex.memcached_blocks.max_memory != null ? var.cortex.memcached_blocks.max_memory : "null", "null")
    memcached_blocks_max_cpu              = try(var.cortex.memcached_blocks.max_cpu != null ? var.cortex.memcached_blocks.max_cpu : "null", "null")
    memcached_blocks_metadata_enable      = try(var.cortex.memcached_blocks_metadata.enable != null ? var.cortex.memcached_blocks_metadata.enable : "true", "true")
    memcached_blocks_metadata_min_memory  = try(var.cortex.memcached_blocks_metadata.min_memory != null ? var.cortex.memcached_blocks_metadata.min_memory : "null", "null")
    memcached_blocks_metadata_min_cpu     = try(var.cortex.memcached_blocks_metadata.min_cpu != null ? var.cortex.memcached_blocks_metadata.min_cpu : "null", "null")
    memcached_blocks_metadata_max_memory  = try(var.cortex.memcached_blocks_metadata.max_memory != null ? var.cortex.memcached_blocks_metadata.max_memory : "null", "null")
    memcached_blocks_metadata_max_cpu     = try(var.cortex.memcached_blocks_metadata.max_cpu != null ? var.cortex.memcached_blocks_metadata.max_cpu : "null", "null")
    distributor_replicas                  = try(var.cortex.distributor.replicas != null ? var.cortex.distributor.replicas : "1", "1")
    distributor_min_memory                = try(var.cortex.distributor.min_memory != null ? var.cortex.distributor.min_memory : "null", "null")
    distributor_min_cpu                   = try(var.cortex.distributor.min_cpu != null ? var.cortex.distributor.min_cpu : "null", "null")
    distributor_max_memory                = try(var.cortex.distributor.max_memory != null ? var.cortex.distributor.max_memory : "null", "null")
    distributor_max_cpu                   = try(var.cortex.distributor.max_cpu != null ? var.cortex.distributor.max_cpu : "null", "null")
    distributor_autoscaling               = try(var.cortex.distributor.autoscaling != null ? var.cortex.distributor.autoscaling : "true", "true")
    distributor_max_replicas              = try(var.cortex.distributor.max_replicas != null ? var.cortex.distributor.max_replicas : "30", "30")
    distributor_min_replicas              = try(var.cortex.distributor.min_replicas != null ? var.cortex.distributor.min_replicas : "2", "2")
    distributor_memory_utilization        = try(var.cortex.distributor.memory_utilization != null ? var.cortex.distributor.memory_utilization : "", "")
    distributor_cpu_utilization           = try(var.cortex.distributor.cpu_utilization != null ? var.cortex.distributor.cpu_utilization : "", "")
  }
}

resource "helm_release" "cortex" {
  count      = local.enable_cortex ? 1 : 0
  name       = "cortex"
  repository = "https://cortexproject.github.io/cortex-helm-chart"
  chart      = "cortex"
  namespace  = kubernetes_namespace.app_environments["cortex"].metadata[0].name
  version    = "1.7.0"

  values = [
    data.template_file.cortex_template[0].rendered
  ]
}
