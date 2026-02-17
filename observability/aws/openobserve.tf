# Create S3 bucket for OpenObserve data storage (auto-generated bucket names)
resource "aws_s3_bucket" "openobserve_data" {
  for_each = local.enable_openobserve ? { for instance in var.openobserve : instance.name => instance if instance.enable } : {}

  bucket        = "${local.cluster_name}-openobserve-${each.value.name}-${var.observability_suffix}"
  force_destroy = false
}

resource "aws_s3_bucket_public_access_block" "openobserve_public_access_block" {
  for_each = aws_s3_bucket.openobserve_data

  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "openobserve_data_encryption" {
  for_each = aws_s3_bucket.openobserve_data
  bucket   = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
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
locals {
  openobserve_templates = local.enable_openobserve ? {
    for instance in var.openobserve :
    instance.name => templatefile(
      "${path.module}/templates/openobserve-values.yaml",
      {
        replica_count       = try(instance.replicaCount, 2)
        cpu_request         = try(instance.min_cpu, "250m")
        memory_request      = try(instance.min_memory, "1Gi")
        cpu_limit           = try(instance.max_cpu, "1")
        memory_limit        = try(instance.max_memory, "2Gi")
        storage_provider    = "s3"
        storage_region      = var.app_region
        storage_bucket_name = aws_s3_bucket.openobserve_data[instance.name].id
        aws_access_key      = var.access_key
        aws_secret_key      = var.access_secret
        root_user_email     = "admin@zop.dev"
        root_user_password  = random_password.openobserve_password[instance.name].result

        additional_env_vars = length(try(instance.env, [])) > 0 ? join("\n",
            [
              for env in instance.env :
              "  - name: ${env.name}\n    value: \"${env.value}\""
            ]) : ""
      }
    )
    if instance.enable
  } : {}
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
    local.openobserve_templates[each.key]
  ]

  depends_on = [
    aws_s3_bucket.openobserve_data,
    kubernetes_namespace.app_environments,
  ]
}
