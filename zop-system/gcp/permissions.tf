resource "random_string" "service_account_name" {
  length   = 16
  numeric  = true
  lower    = true
  upper    = false
  special  = false
}

resource "google_service_account" "kube_management_api_svc_acc" {
  project      = var.provider_id
  account_id   = "zop-system-${regex("[a-z][-a-z0-9]{4,29}", random_string.service_account_name.result)}"
  display_name = "zop-system-${regex("[a-z][-a-z0-9]{4,29}", random_string.service_account_name.result)}"
  description  = "Service account created for zop-system operations"
}

resource "google_service_account_key" "kube_management_api_svc_acc" {
  service_account_id = google_service_account.kube_management_api_svc_acc.email
}

resource "random_string" "zop_system_role" {
  length = 6
  special = false

  lower = true
  upper = false
  numeric = false
}

resource "google_project_iam_custom_role" "zop_system_role" {
  role_id = "zop_system_${random_string.zop_system_role.result}"
  title = "Zop System ${var.cluster_name}"
  permissions = [
    "container.clusters.get",
    "container.nodes.list",
    "container.clusterRoles.list",
    "container.clusterRoles.create",
    "container.clusterRoles.update",
    "container.clusterRoles.delete",
    "container.clusterRoles.get",
    "container.clusterRoleBindings.list",
    "container.clusterRoleBindings.create",
    "container.clusterRoleBindings.update",
    "container.clusterRoleBindings.delete",
    "container.clusterRoleBindings.get",
    "container.storageClasses.get",
    "container.storageClasses.create",
    "container.storageClasses.update",
    "container.storageClasses.delete",
    "container.storageClasses.list",
    "container.thirdPartyObjects.create",
    "container.thirdPartyObjects.update",
    "container.thirdPartyObjects.delete",
    "container.thirdPartyObjects.get",
    "container.thirdPartyObjects.list",
    "container.customResourceDefinitions.create",
    "container.customResourceDefinitions.delete",
    "container.customResourceDefinitions.get",
    "container.customResourceDefinitions.list",
    "container.customResourceDefinitions.update",
    "container.secrets.create"
  ]
}


resource "google_project_iam_member" "zop_system_permissions" {
  project  = var.provider_id
  role     = "projects/${var.provider_id}/roles/${google_project_iam_custom_role.zop_system_role.role_id}"
  member   = "serviceAccount:${google_service_account.kube_management_api_svc_acc.email}"
}

resource "random_password" "kube_management_api_api_key" {
  length = 12
  special = false
}

resource "kubernetes_secret" "kube_management_api_secrets" {
  metadata {
    name      = "zop-system-secret"
    namespace = "zop-system"
  }
  data = {
    CREDENTIALS = base64decode(google_service_account_key.kube_management_api_svc_acc.private_key)
    X_API_KEY   = random_password.kube_management_api_api_key.result
  }
  depends_on = [kubernetes_namespace.app_environments]

}

data "google_secret_manager_secret_version" "zop_system_api_image_pull_secrets" {
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
          "password" = data.google_secret_manager_secret_version.zop_system_api_image_pull_secrets.secret_data
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

    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.kube_management_api_svc_acc.email
    }
  }
  depends_on = [kubernetes_namespace.app_environments]

}

resource "kubernetes_cluster_role_binding" "zop_system_admin_role_binding" {
  metadata {
    name      = "zop_system_role_binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.ksa_zop.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "zop_system_admin_role_binding_gcp_sa" {
  metadata {
    name      = "zop_system_role_binding_gcp_sa"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }

  subject {
    kind      = "User"
    name      = google_service_account.kube_management_api_svc_acc.email
  }
}
