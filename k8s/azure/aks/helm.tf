data "azurerm_kubernetes_cluster" "cluster" {
  name = module.aks.aks_name
  resource_group_name = var.resource_group_name
  depends_on = [module.aks]
}

provider "helm" {
  kubernetes {
    host                   = module.aks.admin_host
    client_certificate     = base64decode(module.aks.admin_client_certificate)
    client_key             = base64decode(module.aks.admin_client_key)
    cluster_ca_certificate = base64decode(module.aks.admin_cluster_ca_certificate)
  }
}

provider "kubectl" {
  host                   = module.aks.admin_host
  client_certificate     = base64decode(module.aks.admin_client_certificate)
  client_key             = base64decode(module.aks.admin_client_key)
  cluster_ca_certificate = base64decode(module.aks.admin_cluster_ca_certificate)
  load_config_file       = false
}