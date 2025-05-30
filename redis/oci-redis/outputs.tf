output "redis" {
  value = var.redis != null ? {
    instance_name  = oci_redis_redis_cluster.redis_cluster.display_name
    port           = "6379"
    instance_url   = oci_redis_redis_cluster.redis_cluster.primary_fqdn
    version        = oci_redis_redis_cluster.redis_cluster.software_version
    machine_type   = oci_redis_redis_cluster.redis_cluster.cluster_mode
    memory_size    = oci_redis_redis_cluster.redis_cluster.node_memory_in_gbs
  } : {}
}