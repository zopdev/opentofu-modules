resource "helm_release" "cassandra" {
  name             = var.name
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "cassandra"
  namespace        = "cassandra"
  create_namespace = true
  set {
    name  = "dbUser.user"
    value = var.admin_user
  }
  set {
    name  = "dbUser.password"
    value = var.cassandra_password
  }
  set {
    name  = "replicaCount"
    value = var.replica_count
  }
  set {
    name  = "persistence.size"
    value = "${var.persistence_size}Gi"
  }
  set {
    name  = "fullnameOverride"
    value = var.name
  }

}