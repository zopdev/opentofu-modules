output "zookeeper_connect_string" {
  value = aws_msk_cluster.msk_cluster.*.zookeeper_connect_string
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.msk_cluster.bootstrap_brokers_tls
}

output "bootstrap_brokers_sasl_scram" {
  value = aws_msk_cluster.msk_cluster.*.bootstrap_brokers_sasl_scram
}

output "bootstrap_brokers" {
  value = aws_msk_cluster.msk_cluster.*.bootstrap_brokers
}
