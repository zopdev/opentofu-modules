resource "kubernetes_cluster_role_binding" "admin" {
  metadata {
    name = "cluster-admins"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"  
  }
  subject {
    kind = "Group"
    name = oci_identity_group.oke_cluster_admins.name
    api_group = "rbac.authorization.k8s.io"
  }
}

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
    name = oci_identity_group.oke_cluster_editors.name
    api_group = "rbac.authorization.k8s.io"
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
    name = oci_identity_group.oke_cluster_viewers.name
    api_group = "rbac.authorization.k8s.io"
  }
}