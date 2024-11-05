resource "kubernetes_cluster_role_binding" "editor" {
  metadata {
    name = "cluster-editors"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }
  subject {
    kind = "Group"
    name = azuread_group.aks_aad_cluster_editors.object_id
  }
}

resource "kubernetes_cluster_role_binding" "viewer" {
  metadata {
    name = "cluster-viewers"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    kind = "Group"
    name = azuread_group.aks_aad_cluster_viewers.object_id
  }
}