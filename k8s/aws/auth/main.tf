# EKS Access Entries Configuration
# This replaces the legacy aws-auth ConfigMap approach

locals {
  system_authenticated_users = concat(var.system_authenticated_admins, var.system_authenticated_editors, var.system_authenticated_viewers)
}

data "aws_caller_identity" "current" {}

# Get cluster information from remote state
locals {
  cluster_prefix = var.shared_services.cluster_prefix != null ? var.shared_services.cluster_prefix : "${var.provider_id}/${var.app_env}/${var.app_name}"
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

data "aws_eks_cluster" "cluster" {
  name = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].cluster_name : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].cluster_name : module.remote_state_azure_cluster[0].cluster_name)
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].cluster_name : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].cluster_name : module.remote_state_azure_cluster[0].cluster_name)
}