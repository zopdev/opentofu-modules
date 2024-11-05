module "cassandra" {
  source             = "../../../cassandra"

  count              = var.cassandra_db == null ? 0 : 1

  name               = kubernetes_namespace.app_environments.metadata[0].name
  admin_user         = var.cassandra_db.admin_user
  cassandra_password = aws_secretsmanager_secret_version.cassandra_secret[0].secret_string
  replica_count      = var.cassandra_db.replica_count
  persistence_size   = var.cassandra_db.persistence_size
}