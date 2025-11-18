data "azurerm_subscription" "current" {}

resource "random_string" "service_principal_name" {
  length   = 16
  numeric  = true
  lower    = true
  upper    = false
  special  = false
}

resource "azuread_application" "kops_kube" {
  display_name  = "kops-kube-${random_string.service_principal_name.result}"
}

resource "azuread_service_principal" "kops_kube_sp" {
  account_enabled = true
  application_id = azuread_application.kops_kube.application_id
}

resource "azuread_service_principal_password" "kops_kube_sp_pwd" {
  service_principal_id = azuread_service_principal.kops_kube_sp.id
}

resource "azurerm_role_assignment" "kops_kube_sp_contributor" {
  scope                =  data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.kops_kube_sp.id
}

resource "azurerm_role_assignment" "kops_kube_sp" {
  scope                =  data.azurerm_kubernetes_cluster.cluster.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azuread_service_principal.kops_kube_sp.id
}

resource "random_password" "kops_kube_api_key" {
  length = 12
  special = false
}

resource "kubernetes_secret" "kops_kube_secrets" {
  metadata {
    name      = "kops-kube-secret"
    namespace = "kube-system"
  }
  data = {
    CREDENTIALS = jsonencode({"appId":azuread_service_principal.kops_kube_sp.application_id,"password":azuread_service_principal_password.kops_kube_sp_pwd.value,"tenantId":data.azurerm_subscription.current.tenant_id,"subscriptionId":data.azurerm_subscription.current.subscription_id })
    X_API_KEY   = random_password.kops_kube_api_key.result
  }
}

data "google_secret_manager_secret_version" "kops_kube_image_pull_secrets" {
  provider = google.shared-services
  secret  = "kops-kube-image-pull-secrets"
}

resource "kubernetes_secret_v1" "image_pull_secrets" {
  metadata {
    name = "kops-kube-image-secrets"
    namespace = "kube-system"
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "us-central1-docker.pkg.dev" = {
          "username" = "_json_key"
          "password" = data.google_secret_manager_secret_version.kops_kube_image_pull_secrets.secret_data
          "email"    = "image-pull@gcr"
        }
      }
    })
  }
}

resource "kubernetes_cluster_role" "kops_kube_reader" {
  metadata {
    name = "kops-kube-reader"
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["cronjobs"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "kops_kube_default_binding" {
  metadata {
    name = "kops-kube-default-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.kops_kube_reader.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }
}