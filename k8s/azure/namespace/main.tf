data "azurerm_subscription" "current" {}

locals {
  cluster_name = var.app_env == "" ? var.app_name : "${var.app_name}-${var.app_env}"
  cluster_name_parts = split("-", local.cluster_name)
  environment = var.app_env == "" ? element(local.cluster_name_parts, length(local.cluster_name_parts) - 1) : var.app_env
  common_tags = merge(var.common_tags,
    tomap({
      Project     = local.cluster_name,
      Provisioner = "TERRAFORM",
      Environment = local.environment,
    }))
}

resource "kubernetes_namespace" "app_environments" {

  metadata {
    name = var.namespace
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}