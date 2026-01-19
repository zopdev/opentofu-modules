data "google_container_cluster" "gke" {
  name = module.gke.name
  location = var.app_region
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    client_certificate     = data.google_container_cluster.gke.master_auth.0.client_certificate
    client_key             = data.google_container_cluster.gke.master_auth.0.client_key
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}

provider "kubectl" {
  load_config_file       = false
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  client_certificate     = data.google_container_cluster.gke.master_auth.0.client_certificate
  client_key             = data.google_container_cluster.gke.master_auth.0.client_key
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}