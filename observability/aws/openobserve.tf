# Create S3 bucket for OpenObserve data storage (auto-generated bucket names)
resource "aws_s3_bucket" "openobserve_data" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}

  bucket        = "${local.cluster_name}-openobserve-${each.value.name}-${var.observability_suffix}"
  force_destroy = true
}

# Generate random password for OpenObserve
resource "random_password" "openobserve_password" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}

  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# Create template for OpenObserve values
data "template_file" "openobserve_template" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}

  template = file("${path.module}/templates/openobserve-values.yaml")
  vars = {
    replica_count       = try(each.value.replicaCount, 2)
    cpu_request         = try(each.value.min_cpu, "250m")
    memory_request      = try(each.value.min_memory, "1Gi")
    cpu_limit           = try(each.value.max_cpu, "1")
    memory_limit        = try(each.value.max_memory, "2Gi")
    storage_provider    = "s3"
    storage_region      = var.app_region
    storage_bucket_name = aws_s3_bucket.openobserve_data[each.key].id
    aws_access_key      = var.access_key
    aws_secret_key      = var.access_secret
    root_user_email     = "admin@zop.dev"
    root_user_password  = random_password.openobserve_password[each.key].result
    additional_env_vars = length(try(each.value.env, [])) > 0 ? join("\n", [for env in each.value.env : "  - name: ${env.name}\n    value: \"${env.value}\""]) : ""
  }
}

# Deploy OpenObserve using Helm
resource "helm_release" "openobserve" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}

  name       = each.value.name
  repository = "https://helm.zop.dev"
  chart      = "openobserve-standalone"
  version    = "v1.0.0"
  namespace  = kubernetes_namespace.app_environments["openobserve"].metadata[0].name

  values = [
    data.template_file.openobserve_template[each.key].rendered
  ]

  depends_on = [
    aws_s3_bucket.openobserve_data,
    kubernetes_namespace.app_environments,
  ]
}
