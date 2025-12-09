locals {
  cluster_prefix = var.shared_services.cluster_prefix != null ? var.shared_services.cluster_prefix : var.app_name

  cluster_id = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].cluster_uid : var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].cluster_uid : module.remote_state_azure_cluster[0].cluster_uid

  cluster_public_endpoint = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].kubernetes_endpoint.public_endpoint : var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].kubernetes_endpoint.public_endpoint : module.remote_state_azure_cluster[0].kubernetes_endpoint.public_endpoint

  cluster_ca_certificate = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].ca_certificate : var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].ca_certificate : module.remote_state_azure_cluster[0].ca_certificate

  db_subnets = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].db_subnets : var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].db_subnets : module.remote_state_azure_cluster[0].db_subnets
}

module "remote_state_gcp_cluster" {
  source        = "../../remote-state/gcp"
  count         = var.shared_services.type == "gcp" ? 1 : 0
  bucket_name   = var.shared_services.bucket
  bucket_prefix = local.cluster_prefix
}

module "remote_state_aws_cluster" {
  source        = "../../remote-state/aws"
  count         = var.shared_services.type == "aws" ? 1 : 0
  bucket_name   = var.shared_services.bucket
  provider_id   = var.shared_services.profile
  bucket_prefix = local.cluster_prefix
  location      = var.shared_services.location
}

module "remote_state_azure_cluster" {
  source          = "../../remote-state/azure"
  count           = var.shared_services.type == "azure" ? 1 : 0
  resource_group  = var.shared_services.resource_group
  storage_account = var.shared_services.storage_account
  container       = var.shared_services.container
  bucket_prefix   = local.cluster_prefix
}

provider "kubernetes" {
  host                   = "https://${local.cluster_public_endpoint}"
  cluster_ca_certificate = base64decode(local.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "oci"
    args        = ["ce", "cluster", "generate-token", "--cluster-id", local.cluster_id, "--region", var.app_region]
  }
}