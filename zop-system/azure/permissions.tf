data "azurerm_subscription" "current" {}

resource "random_string" "service_principal_name" {
  length   = 16
  numeric  = true
  lower    = true
  upper    = false
  special  = false
}

resource "azuread_application" "zop_system" {
  display_name  = "zop-system-${random_string.service_principal_name.result}"
}

resource "azuread_service_principal" "zop_system_sp" {
  account_enabled = true
  application_id = azuread_application.zop_system.application_id
}

resource "azuread_service_principal_password" "zop_system_sp_pwd" {
  service_principal_id = azuread_service_principal.zop_system_sp.id
}

resource "azurerm_role_assignment" "zop_system_sp_contributor" {
  scope                =  data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.zop_system_sp.id
}

resource "azurerm_role_assignment" "zop_system_sp" {
  scope                =  data.azurerm_kubernetes_cluster.cluster.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azuread_service_principal.zop_system_sp.id
}

resource "azuread_group" "aks_aad_cluster_admins" {
  display_name     = "${var.cluster_name}-cluster-admin"
  security_enabled = true
}

resource "azuread_group_member" "aks_aad_cluster_admins" {
  group_object_id  = azuread_group.aks_aad_cluster_admins.object_id
  member_object_id = azuread_service_principal.zop_system_sp.id
}

resource "random_password" "zop_system_api_key" {
  length = 12
  special = false
}

resource "kubernetes_secret" "zop_system_secrets" {
  metadata {
    name      = "zop-system-secret"
    namespace = "zop-system"
  }
  data = {
    CREDENTIALS = jsonencode({"appId":azuread_service_principal.zop_system_sp.application_id,"password":azuread_service_principal_password.zop_system_sp_pwd.value,"tenantId":data.azurerm_subscription.current.tenant_id,"subscriptionId":data.azurerm_subscription.current.subscription_id })
    X_API_KEY   = random_password.zop_system_api_key.result
  }
  depends_on = [kubernetes_namespace.app_environments]
}

data "google_secret_manager_secret_version" "zop_system_image_pull_secrets" {
  provider = google.shared-services
  secret  = "kops-kube-image-pull-secrets"
}

resource "kubernetes_secret_v1" "image_pull_secrets" {
  metadata {
    name = "zop-system-image-secrets"
    namespace = "zop-system"
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "us-central1-docker.pkg.dev" = {
          "username" = "_json_key"
          "password" = data.google_secret_manager_secret_version.zop_system_image_pull_secrets.secret_data
          "email"    = "image-pull@gcr"
        }
      }
    })
  }
  depends_on = [kubernetes_namespace.app_environments]
}

resource "kubernetes_service_account" "ksa_zop" {
  metadata {
    name      = "ksa-zop"
    namespace = "zop-system"
    
    annotations = {
      "azure.workload.identity/client-id" = azuread_application.zop_system.application_id
    }
  }
  depends_on = [kubernetes_namespace.app_environments]
}

resource "kubernetes_role" "zop_system_role" {
  metadata {
    name      = "zop-role"
  }

  rule {
    api_groups = [""]
    resources  = ["rbac"]
    verbs      = ["get", "list", "watch", "create", "delete"]
  }
}

resource "kubernetes_role_binding" "zop_role_binding" {
  metadata {
    name      = "zop-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.zop_system_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.ksa_zop.metadata[0].name
    namespace = kubernetes_service_account.ksa_zop.metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "zop_cluster_role_binding" {
  metadata {
    name = "zop-cluster-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.ksa_zop.metadata[0].name
    namespace = kubernetes_service_account.ksa_zop.metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "zop_cluster_role_binding" {
  metadata {
    name = "zop-cluster-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.ksa_zop.metadata[0].name
    namespace = kubernetes_service_account.ksa_zop.metadata[0].namespace
  }
}