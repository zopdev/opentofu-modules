# AAD K8s cluster admin group / AAD
resource "azuread_group" "aks_aad_cluster_admins" {
  display_name     = "${local.cluster_name}-cluster-admin"
  security_enabled = true
}

# AAD K8s cluster editor group / AAD
resource "azuread_group" "aks_aad_cluster_editors" {
  display_name     = "${local.cluster_name}-cluster-editor"
  security_enabled = true
}

# AAD K8s cluster viewer group / AAD
resource "azuread_group" "aks_aad_cluster_viewers" {
  display_name     = "${local.cluster_name}-cluster-viewer"
  security_enabled = true
}

#data "azuread_user"  "aks_aad_cluster_admins" {
#  for_each            = var.user_access.app_admins != null ? toset(var.user_access.app_admins) : []
#  user_principal_name = each.value
#}

resource "azuread_group_member" "aks_aad_cluster_admins" {
  for_each         = var.user_access.app_admins != null ? toset(var.user_access.app_admins) : []
  group_object_id  = azuread_group.aks_aad_cluster_admins.object_id
  member_object_id = each.value
}

#data "azuread_user"  "aks_aad_cluster_editors" {
#  for_each            = var.user_access.app_editors != null ? toset(var.user_access.app_editors) : []
#  user_principal_name = each.value
#}

resource "azuread_group_member" "aks_aad_cluster_editors" {
  for_each         = var.user_access.app_editors != null ? toset(var.user_access.app_editors) : []
  group_object_id  = azuread_group.aks_aad_cluster_editors.object_id
  member_object_id = each.value
}

#data "azuread_user"  "aks_aad_cluster_viewers" {
#  for_each            = var.user_access.app_viewers != null ? toset(var.user_access.app_viewers) : []
#  user_principal_name = each.value
#}

resource "azuread_group_member" "aks_aad_cluster_viewers" {
  for_each         = var.user_access.app_viewers != null ? toset(var.user_access.app_viewers) : []
  group_object_id  = azuread_group.aks_aad_cluster_viewers.object_id
  member_object_id = each.value
}

resource "azurerm_role_assignment" "aks_aad_cluster_admins" {
  scope                =  data.azurerm_kubernetes_cluster.cluster.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = azuread_group.aks_aad_cluster_admins.object_id
}

resource "azurerm_role_assignment" "aks_aad_cluster_editors" {
  scope                =  data.azurerm_kubernetes_cluster.cluster.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azuread_group.aks_aad_cluster_editors.object_id
}

resource "azurerm_role_assignment" "aks_aad_cluster_viewers" {
  scope                =  data.azurerm_kubernetes_cluster.cluster.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azuread_group.aks_aad_cluster_viewers.object_id
}

data "azurerm_container_registry" "cluster_acr" {
  for_each = { for v in var.acr_list : v => v }
  name                = each.value
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "cluster_to_acr" {
  for_each = { for v in var.acr_list : v => v }
  scope                = data.azurerm_container_registry.cluster_acr[each.key].id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_kubernetes_cluster.cluster.kubelet_identity[0].object_id
}
