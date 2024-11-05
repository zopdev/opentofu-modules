# AAD K8s cluster namespace admins group / AAD
resource "azuread_group" "aks_aad_namespace_admins" {
  display_name = "${local.cluster_name}-${var.namespace}-admins"
  security_enabled = true
}

resource "azuread_group" "aks_aad_namespace_editors" {
  display_name = "${local.cluster_name}-${var.namespace}-editor"
  security_enabled = true
}

resource "azuread_group" "aks_aad_namespace_viewers" {
  display_name = "${local.cluster_name}-${var.namespace}-viewer"
  security_enabled = true
}

#data "azuread_user" "aks_aad_namespace_admins" {
#  for_each            = var.user_access.admins != null ? toset(var.user_access.admins) : []
#  user_principal_name = each.value
#}
#
#data "azuread_user" "aks_aad_namespace_editors" {
#  for_each            = var.user_access.editors != null ? toset(var.user_access.editors) : []
#  user_principal_name = each.value
#}
#
#data "azuread_user" "aks_aad_namespace_viewers" {
#  for_each            = var.user_access.viewers != null ? toset(var.user_access.viewers) : []
#  user_principal_name = each.value
#}

resource "azuread_group_member" "aks_aad_namespace_admins" {
  for_each         = var.user_access.admins != null ? toset(var.user_access.admins) : []
  group_object_id  = azuread_group.aks_aad_namespace_admins.object_id
  member_object_id = each.value
}

resource "azuread_group_member" "aks_aad_namespace_editors" {
  for_each         = var.user_access.editors != null ? toset(var.user_access.editors) : []
  group_object_id  = azuread_group.aks_aad_namespace_editors.object_id
  member_object_id = each.value
}

resource "azuread_group_member" "aks_aad_namespace_viewers" {
  for_each         = var.user_access.viewers != null ? toset(var.user_access.viewers) : []
  group_object_id  = azuread_group.aks_aad_namespace_viewers.object_id
  member_object_id = each.value
}

resource "azurerm_role_assignment" "aks_aad_namespace_admins_user" {
  scope     =  data.azurerm_kubernetes_cluster.cluster.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id = azuread_group.aks_aad_namespace_admins.object_id
}

resource "azurerm_role_assignment" "aks_aad_namespace_editors" {
  scope     =  data.azurerm_kubernetes_cluster.cluster.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id = azuread_group.aks_aad_namespace_editors.object_id
}

resource "azurerm_role_assignment" "aks_aad_namespace_viewers" {
  scope     =  data.azurerm_kubernetes_cluster.cluster.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id = azuread_group.aks_aad_namespace_viewers.object_id
}
