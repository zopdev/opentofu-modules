resource "kubernetes_role_binding" "admin" {
  metadata {
    name      = "namespace-admin"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }
  subject {
    kind = "Group"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
    name = azuread_group.aks_aad_namespace_admins.object_id
  }
}

resource "kubernetes_role_binding" "editor" {
  metadata {
    name      = "namespace-editor"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }
  subject {
    kind = "Group"
    name = azuread_group.aks_aad_namespace_editors.object_id
  }
}

resource "kubernetes_role_binding" "viewer" {
  metadata {
    name      = "namespace-viewer"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    kind = "Group"
    name = azuread_group.aks_aad_namespace_viewers.object_id
  }
}