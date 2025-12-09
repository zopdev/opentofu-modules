data "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.app_region
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  client_certificate     = data.google_container_cluster.gke.master_auth[0].client_certificate
  client_key             = data.google_container_cluster.gke.master_auth[0].client_key
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
}

provider "kubectl" {
  load_config_file       = false
  host                   = "https://${data.google_container_cluster.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  client_certificate     = data.google_container_cluster.gke.master_auth[0].client_certificate
  client_key             = data.google_container_cluster.gke.master_auth[0].client_key
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    client_certificate     = data.google_container_cluster.gke.master_auth[0].client_certificate
    client_key             = data.google_container_cluster.gke.master_auth[0].client_key
    cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
  }
}

terraform {
  backend "gcs" {}
}