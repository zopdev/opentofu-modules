locals {
  users = distinct(concat(coalesce(var.user_access.viewers,[]), coalesce(var.user_access.editors,[]), coalesce(var.user_access.admins,[]) ))
  app_name_role = replace(var.app_name, "-", "_")
  namespace_role = replace(var.namespace, "-", "_")
}

resource "random_string" "namespace_cluster_get_role" {
  length = 4
  special = false

  lower = true
  upper = false
  numeric = false
}

resource "google_project_iam_custom_role" "namespace_cluster_get_role" {
  role_id = "${local.app_name_role}_${local.namespace_role}_${random_string.namespace_cluster_get_role.result}"
  title = "${var.app_name} ${var.namespace} cluster-get-role"
  permissions = [
    "container.clusters.get",
  ]
}

resource "google_project_iam_member" "namespace_cluster_get" {
  for_each = {for k,v in local.users: v => v}
  project  = var.provider_id
  role     = "projects/${var.provider_id}/roles/${google_project_iam_custom_role.namespace_cluster_get_role.role_id}"
  member   = strcontains(each.value, "iam.gserviceaccount.com") ?"serviceAccount:${each.value}":"user:${each.value}"
}

resource "kubernetes_role_binding" "namespace_editor" {
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

resource "kubernetes_role_binding" "namespace_viewer" {
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

resource "kubernetes_role_binding" "namespace_admin" {
  count =  length(coalesce(var.user_access.admins,[])) > 0 ? 1 : 0
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

resource "kubernetes_role_binding" "service_deployment_edit" {
  for_each = google_service_account.service_deployment_svc_acc

  metadata {
    name      = "${each.value.display_name}-edit-binding"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }

  subject {
    kind      = "User"
    name      = each.value.email
    api_group = "rbac.authorization.k8s.io"
  }
}