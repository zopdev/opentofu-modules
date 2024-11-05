resource "kubernetes_namespace" "db_namespace" {
  metadata {
    name = "db"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}