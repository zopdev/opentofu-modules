locals {
  remote_write_config = try([
    for remote in var.tempo.metrics_generator.remote_write : {
      host  = remote.host
      key   = remote.header.key
      value = remote.header.value
    }
  ], {})

  tempo_template = local.enable_tempo ? templatefile(
    "${path.module}/templates/tempo-values.yaml",
    {
      BUCKET_NAME       = oci_objectstorage_bucket.tempo_data[0].name
      OCI_SECRET        = var.access_secret
      OCI_KEY           = var.access_key
      app_region        = var.app_region
      tenancy_namespace = var.tenancy_namespace

      ingester_replicas       = try(var.tempo.ingester.replicas, "1")
      ingester_min_memory     = try(var.tempo.ingester.min_memory, "1Gi")
      ingester_max_memory     = try(var.tempo.ingester.max_memory, "null")
      ingester_min_cpu        = try(var.tempo.ingester.min_cpu, "null")
      ingester_max_cpu        = try(var.tempo.ingester.max_cpu, "null")
      ingester_autoscaling    = try(var.tempo.ingester.autoscaling, "true")
      ingester_min_replicas   = try(var.tempo.ingester.min_replicas, "2")
      ingester_max_replicas   = try(var.tempo.ingester.max_replicas, "30")
      ingester_memory_utilization =
      try(var.tempo.ingester.memory_utilization, "")
      ingester_cpu_utilization =
      try(var.tempo.ingester.cpu_utilization, "")

      distributor_replicas     = try(var.tempo.distributor.replicas, "1")
      distributor_min_memory   = try(var.tempo.distributor.min_memory, "750Mi")
      distributor_max_memory   = try(var.tempo.distributor.max_memory, "null")
      distributor_min_cpu      = try(var.tempo.distributor.min_cpu, "null")
      distributor_max_cpu      = try(var.tempo.distributor.max_cpu, "null")
      distributor_autoscaling  = try(var.tempo.distributor.autoscaling, "true")
      distributor_min_replicas = try(var.tempo.distributor.min_replicas, "2")
      distributor_max_replicas = try(var.tempo.distributor.max_replicas, "30")
      distributor_memory_utilization = try(var.tempo.distributor.memory_utilization, "")
      distributor_cpu_utilization = try(var.tempo.distributor.cpu_utilization, "")
      querier_replicas       = try(var.tempo.querier.replicas, "1")
      queryFrontend_replicas = try(var.tempo.queryFrontend.replicas, "1")
      metrics_generator_enable = try(var.tempo.metrics_generator.enable, false)
      metrics_generator_replicas = try(var.tempo.metrics_generator.replicas, "1")
      metrics_generator_service_graphs_max_items = try(var.tempo.metrics_generator.service_graphs_max_items, "30000")
      metrics_generator_service_graphs_wait = try(var.tempo.metrics_generator.service_graphs_wait, "30s")
      metrics_generator_remote_write_flush_deadline = try(var.tempo.metrics_generator.remote_write_flush_deadline, "2m")
      metrics_generator_remote_write = jsonencode(local.remote_write_config)
      metrics_generator_metrics_ingestion_time_range_slack = try(
        var.tempo.metrics_generator.metrics_ingestion_time_range_slack,
        "40s"
      )
    }
  ) : null
}

resource "oci_objectstorage_bucket" "tempo_data" {
    count           = local.enable_tempo ? 1 : 0
    compartment_id  = var.provider_id
    name            = "${local.cluster_name}-tempo-data-${var.observability_suffix}"
    namespace       = var.tenancy_namespace
}

resource "null_resource" "cleanup_tempo_bucket" {
  count = local.enable_tempo ? 1 : 0

  triggers = {
    bucket_name = oci_objectstorage_bucket.tempo_data[0].name
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

  depends_on = [oci_objectstorage_bucket.tempo_data]
}

resource "helm_release" "tempo" {
  count      = local.enable_tempo ? 1 : 0
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo-distributed"
  namespace  = kubernetes_namespace.app_environments["tempo"].metadata[0].name
  version    = "1.38.0"

  values     =  [
    local.tempo_template
  ]
}