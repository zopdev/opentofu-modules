output "cassandra_passwords" {
  value = var.cassandra_password
}

output "cassandra_host_url" {
  value = "${var.name}.${helm_release.cassandra.namespace}.svc.cluster.local"
}