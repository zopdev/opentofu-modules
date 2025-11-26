resource "oci_objectstorage_bucket" "mimir_data" {
    count           = local.enable_mimir ? 1 : 0
    compartment_id  = var.provider_id
    name            = "${local.cluster_name}-mimir-data-${var.observability_suffix}"
    namespace       = var.tenancy_namespace
}

resource "null_resource" "cleanup_mimir_bucket" {
  count = local.enable_mimir ? 1 : 0

  triggers = {
    bucket_name = oci_objectstorage_bucket.mimir_data[0].name
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

  depends_on = [oci_objectstorage_bucket.mimir_data]
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
    # NGINX expects a file content like: "username:hashed_password"
    # The key must usually be 'auth' or '.htpasswd' depending on the chart version.
    # 'auth' is the safest default for NGINX basic auth.
    auth = "${random_password.mimir_basic_auth_username[0].result}:${bcrypt(random_password.mimir_basic_auth_password[0].result)}"
  }

  type = "Opaque"
}

resource "kubernetes_secret" "mimir-oci-credentials" {
  count = local.enable_mimir ? 1 : 0
  metadata {
    name        = "${local.cluster_name}-mimir-oci-credentials"
    namespace   = kubernetes_namespace.app_environments["mimir"].metadata[0].name
    labels      = { app = var.app_name }
    annotations = {
      "kubernetes.io/service-account.name" = "${local.cluster_name}-mimir-oci-credentials"
    }
  }

  data = {
    "credentials" = "[default]\naws_access_key_id=${var.access_key}\naws_secret_access_key=${var.access_secret}"
  }
  type = "Opaque"

}

data "template_file" "mimir_template" {
  count = local.enable_mimir ? 1 : 0
  template = file("${path.module}/templates/mimir-values.yaml")
  vars = {
    BUCKET_NAME                                 = oci_objectstorage_bucket.mimir_data[0].name
    cluster_name                                = local.cluster_name
    app_region                                  = var.app_region
    "OCI_SECRET"                                = var.access_secret
    "OCI_KEY"                                   = var.access_key
    tenancy_namespace                           = var.tenancy_namespace
    limits_ingestion_rate                       = try(var.mimir.limits.ingestion_rate != null ? var.mimir.limits.ingestion_rate : "250000", "250000")
    limits_ingestion_burst_size                 = try(var.mimir.limits.ingestion_burst_size != null ? var.mimir.limits.ingestion_burst_size : "500000", "500000")
    limits_max_fetched_chunks_per_query         = try(var.mimir.limits.max_fetched_chunks_per_query != null ? var.mimir.limits.max_fetched_chunks_per_query : "3000000", "3000000")
    limits_max_cache_freshness                  = try(var.mimir.limits.max_cache_freshness != null ? var.mimir.limits.max_cache_freshness : "24h", "24h")
    limits_max_outstanding_requests_per_tenant  = try(var.mimir.limits.max_outstanding_requests_per_tenant != null ? var.mimir.limits.max_outstanding_requests_per_tenant : "1000", "1000")
    compactor_replicas                          = try(var.mimir.compactor.replicas != null ? var.mimir.compactor.replicas : "1", "1")
    compactor_persistence_volume_enable         = try(var.mimir.compactor.persistence_volume.enable != null ? var.mimir.compactor.persistence_volume.enable : "true", "true")
    compactor_persistence_volume_size           = try(var.mimir.compactor.persistence_volume.size != null ? var.mimir.compactor.persistence_volume.size : "20Gi", "20Gi")
    compactor_min_cpu                           = try(var.mimir.compactor.min_cpu != null ? var.mimir.compactor.min_cpu : "null", "null")
    compactor_min_memory                        = try(var.mimir.compactor.min_memory != null ? var.mimir.compactor.min_memory : "null", "null")
    compactor_max_cpu                           = try(var.mimir.compactor.max_cpu != null ? var.mimir.compactor.max_cpu : "null", "null")
    compactor_max_memory                        = try(var.mimir.compactor.max_memory != null ? var.mimir.compactor.max_memory : "null", "null")
    ingester_replicas                           = try(var.mimir.ingester.replicas != null ? var.mimir.ingester.replicas : "2", "2")
    ingester_persistence_volume_size            = try(var.mimir.ingester.persistence_volume.size != null ? var.mimir.ingester.persistence_volume.size : "20Gi", "20Gi")
    ingester_min_memory                         = try(var.mimir.ingester.min_memory != null ? var.mimir.ingester.min_memory : "null", "null")
    ingester_min_cpu                            = try(var.mimir.ingester.min_cpu != null ? var.mimir.ingester.min_cpu : "null", "null")
    ingester_max_memory                         = try(var.mimir.ingester.max_memory != null ? var.mimir.ingester.max_memory : "null", "null")
    ingester_max_cpu                            = try(var.mimir.ingester.max_cpu != null ? var.mimir.ingester.max_cpu : "null", "null")
    querier_replicas                            = try(var.mimir.querier.replicas != null ? var.mimir.querier.replicas : "3", "3")
    querier_min_memory                          = try(var.mimir.querier.min_memory != null ? var.mimir.querier.min_memory : "null", "null")
    querier_min_cpu                             = try(var.mimir.querier.min_cpu != null ? var.mimir.querier.min_cpu : "null", "null")
    querier_max_memory                          = try(var.mimir.querier.max_memory != null ? var.mimir.querier.max_memory : "null", "null")
    querier_max_cpu                             = try(var.mimir.querier.max_cpu != null ? var.mimir.querier.max_cpu : "null", "null")
    query_frontend_replicas                     = try(var.mimir.query_frontend.replicas != null ? var.mimir.query_frontend.replicas : "1", "1")
    store_gateway_replication_factor            = try(var.mimir.store_gateway.replication_factor != null ? var.mimir.store_gateway.replication_factor : "3", "3")
    store_gateway_replicas                      = try(var.mimir.store_gateway.replicas != null ? var.mimir.store_gateway.replicas : "1", "1")
    store_gateway_persistence_volume_size       = try(var.mimir.store_gateway.persistence_volume.size != null ? var.mimir.store_gateway.persistence_volume.size : "500Gi", "500Gi")
    store_gateway_min_memory                    = try(var.mimir.store_gateway.min_memory != null ? var.mimir.store_gateway.min_memory : "null", "null")
    store_gateway_min_cpu                       = try(var.mimir.store_gateway.min_cpu != null ? var.mimir.store_gateway.min_cpu : "null", "null")
    store_gateway_max_memory                    = try(var.mimir.store_gateway.max_memory != null ? var.mimir.store_gateway.max_memory : "null", "null")
    store_gateway_max_cpu                       = try(var.mimir.store_gateway.max_cpu != null ? var.mimir.store_gateway.max_cpu : "null", "null")
    distributor_replicas                        = try(var.mimir.distributor.replicas != null ? var.mimir.distributor.replicas : "1", "1")
    distributor_min_memory                      = try(var.mimir.distributor.min_memory != null ? var.mimir.distributor.min_memory : "null", "null")
    distributor_min_cpu                         = try(var.mimir.distributor.min_cpu != null ? var.mimir.distributor.min_cpu : "null", "null")
    distributor_max_memory                      = try(var.mimir.distributor.max_memory != null ? var.mimir.distributor.max_memory : "null", "null")
    distributor_max_cpu                         = try(var.mimir.distributor.max_cpu != null ? var.mimir.distributor.max_cpu : "null", "null")
    mimir_basic_auth_username                    = random_password.mimir_basic_auth_username[0].result
    mimir_basic_auth_password                    = random_password.mimir_basic_auth_password[0].result
  }
}

resource "helm_release" "mimir" {
  count      = local.enable_mimir ? 1 : 0
  name       = "mimir"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "mimir-distributed"
  namespace  = kubernetes_namespace.app_environments["mimir"].metadata[0].name
  version    = "5.1.3"
  values = [
    data.template_file.mimir_template[0].rendered
  ]

  depends_on = [
    kubernetes_secret.mimir-basic-auth
  ]
}