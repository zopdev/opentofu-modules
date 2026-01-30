locals {
  cortex_values = local.enable_cortex ? templatefile("${path.module}/templates/cortex-values.yaml", {
    BUCKET_NAME                         = oci_objectstorage_bucket.cortex_data[0].name
    OCI_SECRET                          = var.access_secret
    OCI_KEY                             = var.access_key
    CLUSTER_NAME                         = local.cluster_name
    APP_REGION                           = var.app_region
    TENANCY_NAMESPACE                     = var.tenancy_namespace

    limits_ingestion_rate                 = try(var.cortex.limits.ingestion_rate, "250000")
    limits_ingestion_burst_size           = try(var.cortex.limits.ingestion_burst_size, "500000")
    limits_max_series_per_metric          = try(var.cortex.limits.max_series_per_metric, "0")
    limits_max_series_per_user            = try(var.cortex.limits.max_series_per_user, "0")
    limits_max_fetched_chunks_per_query   = try(var.cortex.limits.max_fetched_chunks_per_query, "3000000")

    compactor_enable                      = try(var.cortex.compactor.enable, "true")
    compactor_replicas                    = try(var.cortex.compactor.replicas, "1")
    compactor_persistence_volume_enable   = try(var.cortex.compactor.persistence_volume.enable, "true")
    compactor_persistence_volume_size     = try(var.cortex.compactor.persistence_volume.size, "20Gi")
    compactor_min_cpu                     = try(var.cortex.compactor.min_cpu, null)
    compactor_min_memory                  = try(var.cortex.compactor.min_memory, null)
    compactor_max_cpu                     = try(var.cortex.compactor.max_cpu, null)
    compactor_max_memory                  = try(var.cortex.compactor.max_memory, null)

    ingester_replicas                     = try(var.cortex.ingester.replicas, "1")
    ingester_autoscaling                  = try(var.cortex.ingester.autoscaling, "true")
    ingester_min_replicas                 = try(var.cortex.ingester.min_replicas, "2")
    ingester_max_replicas                 = try(var.cortex.ingester.max_replicas, "100")
    ingester_memory_utilization           = try(var.cortex.ingester.memory_utilization, "")
    ingester_cpu_utilization              = try(var.cortex.ingester.cpu_utilization, "")

    querier_replicas                      = try(var.cortex.querier.replicas, "1")
    querier_autoscaling                   = try(var.cortex.querier.autoscaling, "true")
    querier_min_replicas                  = try(var.cortex.querier.min_replicas, "2")
    querier_max_replicas                  = try(var.cortex.querier.max_replicas, "20")
    querier_memory_utilization            = try(var.cortex.querier.memory_utilization, "")
    querier_cpu_utilization               = try(var.cortex.querier.cpu_utilization, "")

    # ... you can continue the rest in the same pattern ...
  }) : null
}

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

resource "helm_release" "cortex" {
  count      = local.enable_cortex ? 1 : 0
  name       = "cortex"
  repository = "https://cortexproject.github.io/cortex-helm-chart"
  chart      = "cortex"
  namespace  = kubernetes_namespace.app_environments["cortex"].metadata[0].name
  version    = "1.7.0"

  values = [
    local.cortex_values
  ]
}
