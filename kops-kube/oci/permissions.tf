resource "random_string" "oci_user_suffix" {
  length  = 16
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "oci_identity_user" "kops_kube" {
  compartment_id = var.provider_id
  name           = "kops-kube-${random_string.oci_user_suffix.result}"
  description    = "Kops kube service user"
  email          = "kops-kube-${random_string.oci_user_suffix.result}@${var.host}"
}

resource "tls_private_key" "kops_kube_user_api_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "oci_identity_api_key" "kops_kube_user_api_key" {
  user_id   = oci_identity_user.kops_kube.id
  key_value = tls_private_key.kops_kube_user_api_key.public_key_pem
}

resource "random_password" "kops_kube_api_key" {
  length  = 12
  special = false
}

resource "oci_identity_group" "kops_kube_group" {
  compartment_id = var.provider_id
  name           = "${var.cluster_name}-cluster-admin-${random_string.oci_user_suffix.result}"
  description    = "OKE Admin group"
}

resource "oci_identity_user_group_membership" "kops_kube_user_membership" {
  user_id  = oci_identity_user.kops_kube.id
  group_id = oci_identity_group.kops_kube_group.id
}

resource "oci_identity_policy" "kops_kube_group_policy" {
  compartment_id = var.provider_id
  name           = "${var.cluster_name}-kops_kube-policy"
  description    = "Allow kops_kube group to manage OKE"
  statements = [
    "Allow group ${oci_identity_group.kops_kube_group.name} to manage cluster-family in compartment id ${var.provider_id}",
  ]
}

resource "kubernetes_secret" "kops_kube_system_secrets" {
  metadata {
    name      = "kops-kube-secret"
    namespace = "kube-system"
  }
  data = {
    CREDENTIALS = jsonencode({
      user_ocid       = oci_identity_user.kops_kube.id,
      tenancy_ocid    = var.provider_id,
      fingerprint     = oci_identity_api_key.kops_kube_user_api_key.fingerprint,
      private_key     = tls_private_key.kops_kube_user_api_key.private_key_pem,
      region          = var.app_region
    })
    X_API_KEY = random_password.kops_kube_api_key.result
  }
}

data "google_secret_manager_secret_version" "kops_kube_image_pull_secrets" {
  provider = google.shared-services
  secret   = "kops-kube-image-pull-secrets"
}

resource "kubernetes_secret_v1" "image_pull_secrets" {
  metadata {
    name      = "kops-kube-image-secrets"
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