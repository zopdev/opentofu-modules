resource "oci_identity_group" "oke_namespace_admins" {
  compartment_id = var.provider_id
  description    = "Admin group for ${local.cluster_name}-${var.namespace} namespace"
  name           = "${local.cluster_name}-${var.namespace}-admins"
}

resource "oci_identity_group" "oke_namespace_editors" {
  compartment_id = var.provider_id
  description    = "Editor group for ${local.cluster_name}-${var.namespace} namespace"
  name           = "${local.cluster_name}-${var.namespace}-editors"
}

resource "oci_identity_group" "oke_namespace_viewers" {
  compartment_id = var.provider_id
  description    = "Viewer group for ${local.cluster_name}-${var.namespace} namespace"
  name           = "${local.cluster_name}-${var.namespace}-viewers"
}

data "oci_identity_users" "admins" {
  compartment_id = var.provider_id
  
  filter {
    name   = "name"
    values = var.user_access.admins != null ? var.user_access.admins : []
  }
}

data "oci_identity_users" "editors" {
  compartment_id = var.provider_id
  
  filter {
    name   = "name"
    values = var.user_access.editors != null ? var.user_access.editors : []
  }
}

data "oci_identity_users" "viewers" {
  compartment_id = var.provider_id
  
  filter {
    name   = "name"
    values = var.user_access.viewers != null ? var.user_access.viewers : []
  }
}

resource "oci_identity_user_group_membership" "admins" {
  count     = length(data.oci_identity_users.admins.users)
  user_id   = data.oci_identity_users.admins.users[count.index].id
  group_id  = oci_identity_group.oke_namespace_admins.id
}

resource "oci_identity_user_group_membership" "editors" {
  count     = length(data.oci_identity_users.editors.users)
  user_id   = data.oci_identity_users.editors.users[count.index].id
  group_id  = oci_identity_group.oke_namespace_editors.id
}

resource "oci_identity_user_group_membership" "viewers" {
  count     = length(data.oci_identity_users.viewers.users)
  user_id   = data.oci_identity_users.viewers.users[count.index].id
  group_id  = oci_identity_group.oke_namespace_viewers.id
}

resource "oci_identity_policy" "oke_cluster_access_policy" {
  compartment_id = var.provider_id
  description    = "Policy allowing access to ${local.cluster_name} OKE cluster"
  name           = "${local.cluster_name}-${var.namespace}-access-policy"

  statements = [
    "Allow group ${oci_identity_group.oke_namespace_admins.name} to manage clusters in compartment id ${var.provider_id}",
    "Allow group ${oci_identity_group.oke_namespace_editors.name} to use clusters in compartment id ${var.provider_id}",
    "Allow group ${oci_identity_group.oke_namespace_viewers.name} to read clusters in compartment id ${var.provider_id}"
  ]
}

## Create user and credential for artifact user
resource "oci_identity_user" "artifact_user" {
  compartment_id = var.provider_id
  name           = "${var.namespace}-artifact-user"
  email          = "${var.namespace}-artifact@${local.domain_name}"
  description    = "User for managing Oracle Artifact Registry"
}

resource "tls_private_key" "artifact_user_api_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "oci_identity_api_key" "artifact_user_api_key" {
  user_id   = oci_identity_user.artifact_user.id
  key_value = tls_private_key.artifact_user_api_key.public_key_pem
}

resource "oci_identity_auth_token" "artifact_user_token" {
  user_id = oci_identity_user.artifact_user.id
  description = "Auth token for artifact-user"
}

resource "oci_identity_group" "artifact_group" {
  compartment_id = var.provider_id
  name           = "${var.namespace}-artifact-group"
  description    = "Group with manage access to OCIR"
}

resource "oci_identity_user_group_membership" "artifact_user_membership" {
  user_id  = oci_identity_user.artifact_user.id
  group_id = oci_identity_group.artifact_group.id
}

resource "oci_identity_policy" "artifact_registry_policy" {
  compartment_id = var.provider_id
  name           = "${var.namespace}-artifact-registry-manage-policy"
  description    = "Allows manage access to Oracle Artifact Registry"
  statements     = [
    "Allow group ${oci_identity_group.artifact_group.name} to manage repos in tenancy",
    "Allow group ${oci_identity_group.artifact_group.name} to manage cluster-family in compartment id ${var.provider_id}"
  ]
}

data "oci_objectstorage_namespace" "tenancy_namespace" {
  compartment_id = var.provider_id
}

resource "kubernetes_secret" "ocir_image_pull" {
  metadata {
    name      = "ocirsecret"
    namespace = var.namespace
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.app_region}.ocir.io" = {
          username = "${data.oci_objectstorage_namespace.tenancy_namespace.namespace}/${oci_identity_user.artifact_user.name}"
          password = oci_identity_auth_token.artifact_user_token.token
          auth     = base64encode("${data.oci_objectstorage_namespace.tenancy_namespace.namespace}/${oci_identity_user.artifact_user.name}:${oci_identity_auth_token.artifact_user_token.token}")
        }
      }
    })
  }
}