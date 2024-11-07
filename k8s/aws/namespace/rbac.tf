resource "kubernetes_role_binding" "admin" {
  count = length(coalesce(var.user_access.admins,[])) > 0 ? 1 : 0

  metadata {
    name      = "namespace-admin"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }
  dynamic "subject" {
    for_each = var.user_access.admins
    content {
      kind = "User"
      name = subject.value
    }
  }
}

resource "kubernetes_role_binding" "editor" {
  count = length(coalesce(var.user_access.editors,[])) > 0 ? 1 : 0

  metadata {
    name      = "namespace-editor"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }
  dynamic "subject" {
    for_each = var.user_access.editors
    content {
      kind = "User"
      name = subject.value
    }
  }
}

resource "kubernetes_role_binding" "viewer" {
  count = length(coalesce(var.user_access.viewers,[])) > 0 ? 1 : 0

  metadata {
    name      = "namespace-viewer"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  dynamic "subject" {
    for_each = var.user_access.viewers
    content {
      kind = "User"
      name = subject.value
    }
  }
}