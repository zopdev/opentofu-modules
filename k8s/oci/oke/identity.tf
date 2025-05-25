data "oci_identity_users" "existing_users" {
  compartment_id = var.provider_id
}

locals {
  input_user_emails = distinct(concat(
    var.user_access.app_admins   != null ? var.user_access.app_admins   : [],
    var.user_access.app_editors  != null ? var.user_access.app_editors  : [],
    var.user_access.app_viewers  != null ? var.user_access.app_viewers  : []
  ))

  existing_oci_users_map = {
    for user in data.oci_identity_users.existing_users.users :
    user.email => true
  }

  tf_managed_users = try(keys(oci_identity_user.oke_users), [])

  managed_users = distinct(concat(
    [for email in local.input_user_emails :
      email if !contains(keys(local.existing_oci_users_map), email)
    ],
    [for email in local.tf_managed_users :
      email if contains(local.input_user_emails, email)
    ]
  ))

  all_users_map = merge(
    { for email, user in oci_identity_user.oke_users : email => user.id },
    {
      for user in data.oci_identity_users.existing_users.users :
      user.email => user.id
      if !contains(local.input_user_emails, user.email)
    }
  )
}

resource "oci_identity_user" "oke_users" {
  for_each = { for email in local.managed_users : email => email }

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
  for_each = var.user_access.app_admins != null ? {
    for email in var.user_access.app_admins : email => email
  } : {}

  user_id  = local.all_users_map[each.key]
  group_id = oci_identity_group.oke_cluster_admins.id

  depends_on = [ oci_identity_user.oke_users ]
}

resource "oci_identity_user_group_membership" "cluster_editors" {
  for_each = var.user_access.app_editors != null ? {
    for email in var.user_access.app_editors : email => email
  } : {}

  user_id  = local.all_users_map[each.key]
  group_id = oci_identity_group.oke_cluster_editors.id

  depends_on = [ oci_identity_user.oke_users ]
}

resource "oci_identity_user_group_membership" "cluster_viewers" {
  for_each = var.user_access.app_viewers != null ? {
    for email in var.user_access.app_viewers : email => email
  } : {}

  user_id  = local.all_users_map[each.key]
  group_id = oci_identity_group.oke_cluster_viewers.id
  
  depends_on = [ oci_identity_user.oke_users ]
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

resource "oci_identity_dynamic_group" "oke_secrets_dynamic_group" {
  compartment_id = var.provider_id
  name           = "${local.cluster_name}-secrets-dynamic-group"
  description    = "Dynamic group for Vault and Secrets access for ${local.cluster_name}"

  matching_rule = "ALL {instance.compartment.id = '${var.provider_id}'}"
}

resource "oci_identity_policy" "oke_secrets_policy" {
  name           = "${local.cluster_name}-secrets-policy"
  description    = "Policy for Vault and Secrets access for OKE nodes"
  compartment_id = var.provider_id
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_secrets_dynamic_group.name} to read secret-bundles in compartment id ${var.provider_id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_secrets_dynamic_group.name} to use secret-family in compartment id ${var.provider_id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.oke_secrets_dynamic_group.name} to manage vaults in compartment id ${var.provider_id}" 
  ]
}