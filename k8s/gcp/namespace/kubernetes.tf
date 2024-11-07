locals {
  cluster_prefix = var.cluster_prefix != "" ? var.cluster_prefix : "${var.provider_id}/${var.app_env}/${var.app_name}"
}
data "terraform_remote_state" "infra_output" {
  backend  = "gcs"
  config = {
    bucket   = var.bucket_name
    prefix   = "${local.cluster_prefix}/terraform.tfstate"
  }
}

data "google_container_cluster" "gke" {
  name     = data.terraform_remote_state.infra_output.outputs.cluster_name
  location = var.app_region
}

# Kubernetes provider
# https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes

# The Kubernetes provider is included in this file so the EKS module can complete successfully. Otherwise, it throws an error when creating `kubernetes_config_map.aws_auth`.
# You should **not** schedule deployments and services in this workspace. This keeps workspaces modular (one for provision EKS, another for scheduling Kubernetes resources) as per best practices.

provider "kubernetes" {
  host                   = "https://${data.terraform_remote_state.infra_output.outputs.kubernetes_endpoint}"
  token                  = data.google_client_config.default.access_token
  client_certificate     = data.google_container_cluster.gke.master_auth.0.client_certificate
  client_key             = data.google_container_cluster.gke.master_auth.0.client_key
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infra_output.outputs.ca_certificate)
}

provider "kubectl" {
  load_config_file       = false
  host                   = "https://${data.terraform_remote_state.infra_output.outputs.kubernetes_endpoint}"
  token                  = data.google_client_config.default.access_token
  client_certificate     = data.google_container_cluster.gke.master_auth.0.client_certificate
  client_key             = data.google_container_cluster.gke.master_auth.0.client_key
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infra_output.outputs.ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.terraform_remote_state.infra_output.outputs.kubernetes_endpoint}"
    token                  = data.google_client_config.default.access_token
    client_certificate     = data.google_container_cluster.gke.master_auth.0.client_certificate
    client_key             = data.google_container_cluster.gke.master_auth.0.client_key
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infra_output.outputs.ca_certificate)
  }
}

terraform {
  backend "gcs" {}
}