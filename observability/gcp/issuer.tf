resource "kubernetes_secret_v1" "namespace-cert-replicator" {
  for_each = toset([for env in keys(local.app_namespaces) : env if env != "default" && local.app_namespaces[env] != null])
  metadata {
    name = "tls-secret-replica"
    namespace = kubernetes_namespace.app_environments[each.key].metadata.0.name
    annotations = {
      "replicator.v1.mittwald.de/replicate-from" = "cert-manager/wildcard-dns"
    }
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.key" = ""
    "tls.crt" = ""
  }
  lifecycle {
    ignore_changes = all
  }
}