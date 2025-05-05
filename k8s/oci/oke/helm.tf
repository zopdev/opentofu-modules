provider "helm" {
  kubernetes {
    host                   = "https://${module.oke.cluster_endpoints.public_endpoint}"
    cluster_ca_certificate = base64decode(module.oke.cluster_ca_cert)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "oci"
      args        = ["ce", "cluster", "generate-token", "--cluster-id", module.oke.cluster_id, "--region", var.app_region]
    }
  }
}

provider "kubectl" {
  host                   = "https://${module.oke.cluster_endpoints.public_endpoint}"
  cluster_ca_certificate = base64decode(module.oke.cluster_ca_cert)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "oci"
    args        = ["ce", "cluster", "generate-token", "--cluster-id", module.oke.cluster_id, "--region", var.app_region]
  }
  load_config_file = false
}