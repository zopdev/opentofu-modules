resource "oci_redis_redis_cluster" "redis_cluster" {
    compartment_id            = var.provider_id
    display_name              = var.redis.name
    node_count                = var.redis.node_count
    node_memory_in_gbs        = var.redis.memory_size
    software_version          = var.redis.redis_version
    
    subnet_id                 = module.remote_state_oci_cluster.0.db_subnets
}

resource "kubernetes_service" "redis_external" {
  metadata {
    name      = "${var.redis.name}-${var.namespace}-redis"
    namespace = var.namespace
  }

  spec {
    type          = "ExternalName"
    external_name = oci_redis_redis_cluster.redis_cluster.primary_fqdn

    port {
      port = 6379
    }
  }
}