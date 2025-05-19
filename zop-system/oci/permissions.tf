resource "random_string" "oci_user_suffix" {
  length  = 16
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "oci_identity_user" "zop_user" {
  compartment_id = var.provider_id
  name           = "zop-user-${random_string.oci_user_suffix.result}"
  description    = "Zop system service user"
  email          = "zop-system-${random_string.oci_user_suffix.result}@${var.host}"
}

resource "tls_private_key" "zop_user_api_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "oci_identity_api_key" "zop_user_api_key" {
  user_id   = oci_identity_user.zop_user.id
  key_value = tls_private_key.zop_user_api_key.public_key_pem
}

resource "random_password" "zop_system_api_key" {
  length  = 12
  special = false
}

resource "oci_identity_group" "zop_group" {
  compartment_id = var.provider_id
  name           = "${var.cluster_name}-cluster-admin-${random_string.oci_user_suffix.result}"
  description    = "OKE Admin group"
}

resource "oci_identity_user_group_membership" "zop_user_membership" {
  user_id  = oci_identity_user.zop_user.id
  group_id = oci_identity_group.zop_group.id
}

resource "oci_identity_policy" "zop_group_policy" {
  compartment_id = var.provider_id
  name           = "${var.cluster_name}-zop-policy"
  description    = "Allow Zop group to manage OKE"
  statements = [
    "Allow group ${oci_identity_group.zop_group.name} to manage cluster-family in compartment id ${var.provider_id}",
  ]
}

resource "kubernetes_secret" "zop_system_secrets" {
  metadata {
    name      = "zop-system-secret"
    namespace = "zop-system"
  }
  data = {
    CREDENTIALS = jsonencode({
      user_ocid       = oci_identity_user.zop_user.id,
      tenancy_ocid    = var.provider_id,
      fingerprint     = oci_identity_api_key.zop_user_api_key.fingerprint,
      private_key     = tls_private_key.zop_user_api_key.private_key_pem,
      region          = var.app_region
    })
    X_API_KEY = random_password.zop_system_api_key.result
  }
  depends_on = [kubernetes_namespace.app_environments]
}

data "google_secret_manager_secret_version" "zop_system_image_pull_secrets" {
  provider = google.shared-services
  secret   = "kops-kube-image-pull-secrets"
}

resource "kubernetes_secret_v1" "image_pull_secrets" {
  metadata {
    name      = "zop-system-image-secrets"
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
      "oci.workload.identity/subject" = oci_identity_user.zop_user.name
    }
  }
  depends_on = [kubernetes_namespace.app_environments]
}

resource "kubernetes_role" "zop_system_role" {
  metadata {
    name      = "zop-role"
    namespace = "zop-system"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "secrets", "configmaps"]
    verbs      = ["get", "list", "watch", "create", "delete"]
  }
}

resource "kubernetes_role_binding" "zop_role_binding" {
  metadata {
    name      = "zop-role-binding"
    namespace = "zop-system"
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

resource "kubernetes_cluster_role_binding" "zop_cluster_role_binding_cluster_admin" {
  metadata {
    name = "zop-cluster-role-binding-cluster-admin"
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
