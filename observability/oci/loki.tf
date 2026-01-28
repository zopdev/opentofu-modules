locals {
  loki_values = local.enable_loki ? templatefile("${path.module}/templates/loki-values.yaml", {
    BUCKET_NAME           = oci_objectstorage_bucket.loki_data[0].name
    OCI_SECRET            = var.access_secret
    OCI_KEY               = var.access_key
    APP_REGION            = var.app_region
    TENANCY_NAMESPACE     = var.tenancy_namespace
    CLUSTER_BUCKET_NAME   = "${local.cluster_name}-loki-data-${var.observability_suffix}"

    # Ingester
    ingester_replicas        = try(var.loki.ingester.replicas, "1")
    ingester_min_memory      = try(var.loki.ingester.min_memory, "1Gi")
    ingester_max_memory      = try(var.loki.ingester.max_memory, null)
    ingester_min_cpu         = try(var.loki.ingester.min_cpu, null)
    ingester_max_cpu         = try(var.loki.ingester.max_cpu, null)
    ingester_autoscaling     = try(var.loki.ingester.autoscaling, "true")
    ingester_min_replicas    = try(var.loki.ingester.min_replicas, "2")
    ingester_max_replicas    = try(var.loki.ingester.max_replicas, "30")
    ingester_memory_utilization = try(var.loki.ingester.memory_utilization, "")
    ingester_cpu_utilization    = try(var.loki.ingester.cpu_utilization, "")

    # Distributor
    distributor_replicas        = try(var.loki.distributor.replicas, "1")
    distributor_min_memory      = try(var.loki.distributor.min_memory, "512Mi")
    distributor_max_memory      = try(var.loki.distributor.max_memory, "1Gi")
    distributor_min_cpu         = try(var.loki.distributor.min_cpu, "250m")
    distributor_max_cpu         = try(var.loki.distributor.max_cpu, "1")
    distributor_autoscaling     = try(var.loki.distributor.autoscaling, "true")
    distributor_min_replicas    = try(var.loki.distributor.min_replicas, "2")
    distributor_max_replicas    = try(var.loki.distributor.max_replicas, "30")
    distributor_memory_utilization = try(var.loki.distributor.memory_utilization, "")
    distributor_cpu_utilization    = try(var.loki.distributor.cpu_utilization, "")

    # Querier
    querier_replicas        = try(var.loki.querier.replicas, "4")
    querier_min_memory      = try(var.loki.querier.min_memory, "500Mi")
    querier_max_memory      = try(var.loki.querier.max_memory, null)
    querier_min_cpu         = try(var.loki.querier.min_cpu, "100m")
    querier_max_cpu         = try(var.loki.querier.max_cpu, null)
    querier_autoscaling     = try(var.loki.querier.autoscaling, "true")
    querier_min_replicas    = try(var.loki.querier.min_replicas, "2")
    querier_max_replicas    = try(var.loki.querier.max_replicas, "6")
    querier_memory_utilization = try(var.loki.querier.memory_utilization, "")
    querier_cpu_utilization    = try(var.loki.querier.cpu_utilization, "")

    # Query Frontend
    query_frontend_replicas     = try(var.loki.queryFrontend.replicas, "1")
    query_frontend_min_memory   = try(var.loki.queryFrontend.min_memory, "250Mi")
    query_frontend_max_memory   = try(var.loki.queryFrontend.max_memory, null)
    query_frontend_min_cpu      = try(var.loki.queryFrontend.min_cpu, null)
    query_frontend_max_cpu      = try(var.loki.queryFrontend.max_cpu, null)
    query_frontend_autoscaling  = try(var.loki.queryFrontend.autoscaling, "true")
    query_frontend_min_replicas = try(var.loki.queryFrontend.min_replicas, "1")
    query_frontend_max_replicas = try(var.loki.queryFrontend.max_replicas, "6")
    query_frontend_memory_utilization = try(var.loki.queryFrontend.memory_utilization, "")
    query_frontend_cpu_utilization    = try(var.loki.queryFrontend.cpu_utilization, "")
  }) : null
}

resource "oci_objectstorage_bucket" "loki_data" {
    count           = local.enable_loki ? 1 : 0    
    compartment_id  = var.provider_id
    name            = "${local.cluster_name}-loki-data-${var.observability_suffix}"
    namespace       = var.tenancy_namespace
}

resource "null_resource" "cleanup_loki_bucket" {
  count = local.enable_loki ? 1 : 0

  triggers = {
    bucket_name = oci_objectstorage_bucket.loki_data[0].name
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

  depends_on = [oci_objectstorage_bucket.loki_data]
}

resource "helm_release" "loki" {
  count      = local.enable_loki ? 1 : 0
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-distributed"
  namespace  = kubernetes_namespace.app_environments["loki"].metadata[0].name
  version    = "0.68.0"

  values = [
    local.loki_values
  ]
}