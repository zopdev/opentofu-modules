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
    kind      = "Group"
    name      = oci_identity_group.oke_namespace_admins.name
    api_group = "rbac.authorization.k8s.io"
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
    kind      = "Group"
    name      = oci_identity_group.oke_namespace_editors.name
    api_group = "rbac.authorization.k8s.io"
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
    kind      = "Group"
    name      = oci_identity_group.oke_namespace_viewers.name
    api_group = "rbac.authorization.k8s.io"
  }
}