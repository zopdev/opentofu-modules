locals {
  cluster_prefix = var.shared_services.cluster_prefix != null ? var.shared_services.cluster_prefix : var.app_name
  cluster_name = var.app_env != "" ? "${var.app_name}-${var.app_env}" : "${var.app_name}"
}

module "remote_state_gcp_cluster" {
  source         = "../../remote-state/gcp"
  count          = var.shared_services.type == "gcp" ? 1 : 0
  bucket_name    = var.shared_services.bucket
  bucket_prefix  = local.cluster_prefix
}

module "remote_state_aws_cluster" {
  source         = "../../remote-state/aws"
  count          = var.shared_services.type == "aws" ? 1 : 0
  bucket_name    = var.shared_services.bucket
  provider_id    = var.shared_services.profile
  bucket_prefix  = local.cluster_prefix
  location       = var.shared_services.location
}

module "remote_state_azure_cluster" {
  source          = "../../remote-state/azure"
  count           = var.shared_services.type == "azure" ? 1 : 0
  resource_group  = var.shared_services.resource_group
  storage_account = var.shared_services.storage_account
  container       = var.shared_services.container
  bucket_prefix   = local.cluster_prefix
}

data "azurerm_kubernetes_cluster" "cluster" {
  name                = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].cluster_name : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].cluster_name : module.remote_state_azure_cluster[0].cluster_name)
  resource_group_name = var.resource_group_name
}

provider "kubernetes" {
    host                   = data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.cluster_ca_certificate)
}

data "azurerm_key_vault" "secrets" {
  name = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].azurerm_key_vault_name : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].azurerm_key_vault_name : module.remote_state_azure_cluster[0].azurerm_key_vault_name)
  resource_group_name = var.resource_group_name
}

data "azurerm_virtual_network" "avn" {
  name  =  var.vpc
  resource_group_name = var.resource_group_name
}

resource "azurerm_redis_cache" "redis_cluster" {
  name                 = var.redis.name != "" && var.redis.name != null ? var.redis.name : "${local.cluster_name}-${var.namespace}-redis"
  location             = var.app_region
  resource_group_name  = var.resource_group_name
  sku_name             = var.redis.sku_name
  capacity             = var.redis.redis_cache_capacity
  family               = var.redis.redis_cache_family
  non_ssl_port_enabled = var.redis.redis_enable_non_ssl_port
  tags                 = var.tags
}

resource "kubernetes_service" "redis_service" {
  metadata {
    name            = var.redis.name != "" && var.redis.name != null ? "${var.redis.name}-${var.namespace}-redis" : "${var.namespace}-redis"
    namespace       = var.namespace
  }
  spec {
    type            = "ExternalName"
    external_name   = azurerm_redis_cache.redis_cluster.hostname
    port {
      port = azurerm_redis_cache.redis_cluster.port
    }
  }
}

resource "azurerm_key_vault_secret" "redis_access_key" {
  name         = var.redis.name != "" && var.redis.name != null ? "${var.redis.name}-${var.namespace}-redis-secret" : "${local.cluster_name}-${var.namespace}-redis-secret"
  value        = azurerm_redis_cache.redis_cluster.primary_access_key
  key_vault_id = data.azurerm_key_vault.secrets.id
}