locals {
  cluster_prefix = var.shared_services.cluster_prefix != null ? var.shared_services.cluster_prefix : var.app_name
}

module "remote_state_gcp_cluster" {
  source         = "../../../remote-state/gcp"
  count          = var.shared_services.type == "gcp" ? 1 : 0
  bucket_name    = var.shared_services.bucket
  bucket_prefix  = local.cluster_prefix
}

module "remote_state_aws_cluster" {
  source         = "../../../remote-state/aws"
  count          = var.shared_services.type == "aws" ? 1 : 0
  bucket_name    = var.shared_services.bucket
  provider_id    = var.shared_services.profile
  bucket_prefix  = local.cluster_prefix
  location       = var.shared_services.location
}

module "remote_state_azure_cluster" {
  source          = "../../../remote-state/azure"
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

provider "kubectl" {
  host                   = data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.cluster_ca_certificate)
  token                  = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].cluster_host : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].cluster_host : module.remote_state_azure_cluster[0].cluster_host)
  load_config_file       = false
}

provider "kubernetes" {
    host                   = data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.cluster_ca_certificate)
  }
}