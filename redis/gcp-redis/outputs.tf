output "redis" {
  value = var.redis != null ? {
    instance_name  = var.redis.replica_count > 1 ? google_redis_instance.redis_cluster.0.name : google_redis_instance.redis.0.name
    instance_url   = var.redis.replica_count > 1 ? google_redis_instance.redis_cluster.0.host : google_redis_instance.redis.0.host
    port           = var.redis.replica_count > 1 ? google_redis_instance.redis_cluster.0.port : google_redis_instance.redis.0.port
    version        = var.redis.replica_count > 1 ? google_redis_instance.redis_cluster.0.redis_version : google_redis_instance.redis.0.redis_version
    machine_type   = var.redis.replica_count > 1 ? google_redis_instance.redis_cluster.0.tier : google_redis_instance.redis.0.tier
    memory_size    = var.redis.replica_count > 1 ? google_redis_instance.redis_cluster.0.memory_size_gb : google_redis_instance.redis.0.memory_size_gb
    firewall_name  = google_compute_firewall.redis-firewall.name
  } : {}
}