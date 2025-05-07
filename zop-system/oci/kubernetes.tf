
locals {
  cluster_prefix = var.shared_services.cluster_prefix
}

data "oci_containerengine_clusters" "oke" {
    compartment_id = var.provider_id
    name           = var.cluster_name
}

module "remote_state_oci_cluster" {
  source        = "../../remote-state/oci"
  count         = var.cluster_ca_cert == null ? (var.shared_services.type == "oci" ? 1 : 0) : 0
  bucket_name   = var.shared_services.bucket
  bucket_prefix = local.cluster_prefix
}

provider "kubernetes" {
  host                   = "https://${data.oci_containerengine_clusters.oke.clusters[0].endpoints[0].public_endpoint}"
  cluster_ca_certificate = base64decode(var.cluster_ca_cert != null && var.cluster_ca_cert != "" ? var.cluster_ca_cert : module.remote_state_oci_cluster[0].ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "oci"
    args        = ["ce", "cluster", "generate-token", "--cluster-id", data.oci_containerengine_clusters.oke.id, "--region", var.app_region]
  }
}

provider "helm" {
  kubernetes {
     host                   = "https://${data.oci_containerengine_clusters.oke.clusters[0].endpoints[0].public_endpoint}"
     cluster_ca_certificate = base64decode(var.cluster_ca_cert != null && var.cluster_ca_cert != "" ? var.cluster_ca_cert : module.remote_state_oci_cluster[0].ca_certificate)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "oci"
      args        = ["ce", "cluster", "generate-token", "--cluster-id", data.oci_containerengine_clusters.oke.id, "--region", var.app_region]
    }
  }
}