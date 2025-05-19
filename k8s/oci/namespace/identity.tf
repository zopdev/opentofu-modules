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
  name           = "${local.cluster_name}-access-policy"

  statements = [
    "Allow group ${oci_identity_group.oke_namespace_admins.name} to manage clusters in compartment id ${var.provider_id}",
    "Allow group ${oci_identity_group.oke_namespace_editors.name} to use clusters in compartment id ${var.provider_id}",
    "Allow group ${oci_identity_group.oke_namespace_viewers.name} to read clusters in compartment id ${var.provider_id}"
  ]
}