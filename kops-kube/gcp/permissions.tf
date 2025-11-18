resource "random_string" "service_account_name" {
  length   = 16
  numeric  = true
  lower    = true
  upper    = false
  special  = false
}

resource "google_service_account" "kops_kube_svc_acc" {
  project      = var.provider_id
  account_id   = "kops-kube-${regex("[a-z][-a-z0-9]{4,29}", random_string.service_account_name.result)}"
  display_name = "kops-kube-${regex("[a-z][-a-z0-9]{4,29}", random_string.service_account_name.result)}"
  description  = "Service account created for kops-kube operations"
}

resource "google_service_account_key" "kops_kube_svc_acc" {
  service_account_id = google_service_account.kops_kube_svc_acc.email
}

resource "google_project_iam_member" "get_permission" {
  project  = var.provider_id
  role     = "projects/${var.provider_id}/roles/${data.terraform_remote_state.infra_output.outputs.cluster_get_role}"
  member   = "serviceAccount:${google_service_account.kops_kube_svc_acc.email}"
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
    CREDENTIALS = base64decode(google_service_account_key.kops_kube_svc_acc.private_key)
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