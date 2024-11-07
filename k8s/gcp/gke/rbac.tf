locals {
  users = concat(coalesce(var.user_access.app_editors,[]), coalesce(var.user_access.app_viewers,[]) )
  app_name_role = replace(var.app_name, "-", "_")

}

resource "random_string" "cluster_get_role" {
  length = 6
  special = false

  lower = true
  upper = false
  numeric = false
}

resource "google_project_iam_custom_role" "cluster_get_role" {
  role_id = "${local.app_name_role}_clusterGetRole_${random_string.cluster_get_role.result}"
  title = "${var.app_name} cluster-get-role"
  permissions = [
    "container.clusters.get",
  ]
}

resource "google_project_iam_custom_role" "cluster_admin" {
  role_id = "${local.app_name_role}_clusterAdminRole_${random_string.cluster_get_role.result}"
  title = "${local.app_name_role} cluster-Admin-role"
  permissions = [
    "container.clusters.get",
    "container.nodes.list",
    "container.clusterRoles.list",
    "container.clusterRoles.create",
    "container.clusterRoles.update",
    "container.clusterRoles.delete",
    "container.clusterRoles.get",
    "container.clusterRoleBindings.list",
    "container.clusterRoleBindings.create",
    "container.clusterRoleBindings.update",
    "container.clusterRoleBindings.delete",
    "container.clusterRoleBindings.get",
    "container.storageClasses.get",
    "container.storageClasses.create",
    "container.storageClasses.update",
    "container.storageClasses.delete",
    "container.storageClasses.list",
    "container.thirdPartyObjects.create",
    "container.thirdPartyObjects.update",
    "container.thirdPartyObjects.delete",
    "container.thirdPartyObjects.get",
    "container.thirdPartyObjects.list",
    "container.customResourceDefinitions.create",
    "container.customResourceDefinitions.delete",
    "container.customResourceDefinitions.get",
    "container.customResourceDefinitions.list",
    "container.customResourceDefinitions.update"
  ]
}

resource "google_project_iam_member" "cluster_get" {
  count    = length(local.users)
  project  = var.provider_id
  role     = "projects/${var.provider_id}/roles/${google_project_iam_custom_role.cluster_get_role.role_id}"
  member   = "user:${local.users[count.index]}"
  depends_on = [google_project_iam_custom_role.cluster_get_role]
}

resource "google_project_iam_member" "cluster_admin" {
  count    = length(coalesce(var.user_access.app_admins,[]))
  project  = var.provider_id
  role     = "projects/${var.provider_id}/roles/${google_project_iam_custom_role.cluster_admin.role_id}"
  member   = "user:${var.user_access.app_admins[count.index]}"
  depends_on = [google_project_iam_custom_role.cluster_admin]
}

resource "google_project_iam_member" "cluster_engine_admin" {
  count    = length(coalesce(var.user_access.app_admins,[]))
  project  = var.provider_id
  role     = "roles/container.admin"
  member   = "user:${var.user_access.app_admins[count.index]}"
  depends_on = [google_project_iam_custom_role.cluster_admin]
}

resource "kubernetes_cluster_role_binding" "editor" {
  count = length(coalesce(var.user_access.app_editors,[])) > 0  ? 1 : 0
  metadata {
    name      = "${local.cluster_name}-cluster-editor"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }

  dynamic "subject" {
    for_each = var.user_access.app_editors
    content {
      kind = "User"
      name = subject.value
    }
  }

}

resource "kubernetes_cluster_role_binding" "viewer" {
  count =  length(coalesce(var.user_access.app_viewers,[])) > 0  ? 1 : 0
  metadata {
    name      = "${local.cluster_name}-cluster-viewer"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }

  dynamic "subject" {
    for_each = var.user_access.app_viewers
    content {
      kind = "User"
      name = subject.value
    }
  }
}

resource "kubernetes_cluster_role_binding" "admin" {
  count = length(coalesce(var.user_access.app_admins,[])) > 0 ? 1: 0
  metadata {
    name      = "${local.cluster_name}-cluster-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }

  dynamic "subject" {
    for_each = var.user_access.app_admins
    content {
      kind = "User"
      name = subject.value
    }
  }
}
