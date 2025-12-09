locals {
  cluster_prefix = var.shared_services.cluster_prefix != null ? var.shared_services.cluster_prefix : "${var.provider_id}/${var.app_env}/${var.app_name}"
}

module "remote_state_gcp_cluster" {
  source        = "../../../remote-state/gcp"
  count         = var.shared_services.type == "gcp" ? 1 : 0
  bucket_name   = var.shared_services.bucket
  bucket_prefix = local.cluster_prefix
}

module "remote_state_aws_cluster" {
  source        = "../../../remote-state/aws"
  count         = var.shared_services.type == "aws" ? 1 : 0
  bucket_name   = var.shared_services.bucket
  provider_id   = var.shared_services.profile
  bucket_prefix = local.cluster_prefix
  location      = var.shared_services.location
}

module "remote_state_azure_cluster" {
  source          = "../../../remote-state/azure"
  count           = var.shared_services.type == "azure" ? 1 : 0
  resource_group  = var.shared_services.resource_group
  storage_account = var.shared_services.storage_account
  container       = var.shared_services.container
  bucket_prefix   = local.cluster_prefix
}

data "aws_eks_cluster" "cluster" {
  name = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].cluster_name : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].cluster_name : module.remote_state_azure_cluster[0].cluster_name)
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].cluster_name : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].cluster_name : module.remote_state_azure_cluster[0].cluster_name)
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}


provider "kubectl" {
  load_config_file       = false
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}