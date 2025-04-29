resource "oci_identity_user" "oke_users" {
  for_each       = {
    for email in concat(
      var.user_access.app_admins != null ? var.user_access.app_admins : [],
      var.user_access.app_editors != null ? var.user_access.app_editors : [],
      var.user_access.app_viewers != null ? var.user_access.app_viewers : []
    ) : email => email
  }
  
  compartment_id = var.provider_id
  name           = each.value 
  description    = "User for Kubernetes cluster access"
  email          = each.value
}

resource "oci_identity_group" "oke_cluster_admins" {
  name           = "${local.cluster_name}-cluster-admin"
  description    = "Admin group for ${local.cluster_name} Kubernetes cluster"
  compartment_id = var.provider_id
}

resource "oci_identity_group" "oke_cluster_editors" {
  name           = "${local.cluster_name}-cluster-editor"
  description    = "Editor group for ${local.cluster_name} Kubernetes cluster"
  compartment_id = var.provider_id
}

resource "oci_identity_group" "oke_cluster_viewers" {
  name           = "${local.cluster_name}-cluster-viewer"
  description    = "Viewer group for ${local.cluster_name} Kubernetes cluster"
  compartment_id = var.provider_id
}

resource "oci_identity_user_group_membership" "cluster_admins" {
  for_each = var.user_access.app_admins != null ? toset(var.user_access.app_admins) : []
  
  user_id  = oci_identity_user.oke_users[each.value].id
  group_id = oci_identity_group.oke_cluster_admins.id
}

resource "oci_identity_user_group_membership" "cluster_editors" {
  for_each = var.user_access.app_editors != null ? toset(var.user_access.app_editors) : []
  
  user_id  = oci_identity_user.oke_users[each.value].id
  group_id = oci_identity_group.oke_cluster_editors.id
}

resource "oci_identity_user_group_membership" "cluster_viewers" {
  for_each = var.user_access.app_viewers != null ? toset(var.user_access.app_viewers) : []
  
  user_id  = oci_identity_user.oke_users[each.value].id
  group_id = oci_identity_group.oke_cluster_viewers.id
}

resource "oci_identity_policy" "oke_admin_policy" {
  name           = "${local.cluster_name}-admin-policy"
  description    = "Policy for Kubernetes cluster admin access"
  compartment_id = var.provider_id
  statements     = [
    "Allow group ${oci_identity_group.oke_cluster_admins.name} to manage cluster-family in compartment id ${var.provider_id}",
    "Allow group ${oci_identity_group.oke_cluster_admins.name} to manage virtual-network-family in compartment id ${var.provider_id}"
  ]
}

resource "oci_identity_policy" "oke_editor_policy" {
  name           = "${local.cluster_name}-editor-policy"
  description    = "Policy for Kubernetes cluster editor access"
  compartment_id = var.provider_id
  statements     = [
    "Allow group ${oci_identity_group.oke_cluster_editors.name} to use cluster-family in compartment id ${var.provider_id}",
    "Allow group ${oci_identity_group.oke_cluster_editors.name} to read virtual-network-family in compartment id ${var.provider_id}"
  ]
}

resource "oci_identity_policy" "oke_viewer_policy" {
  name           = "${local.cluster_name}-viewer-policy"
  description    = "Policy for Kubernetes cluster viewer access"
  compartment_id = var.provider_id
  statements     = [
    "Allow group ${oci_identity_group.oke_cluster_viewers.name} to read cluster-family in compartment id ${var.provider_id}",
    "Allow group ${oci_identity_group.oke_cluster_viewers.name} to read virtual-network-family in compartment id ${var.provider_id}"
  ]
}

