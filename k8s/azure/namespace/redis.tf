module "local_redis" {
  count         = try(var.local_redis.enable,false) ? 1 : 0

  source        = "../../../redis/local"
  namespace     = var.namespace
  disk_size     = var.local_redis.disk_size != null ? var.local_redis.disk_size : "10G"
  storage_class = var.local_redis.storage_class != null ? var.local_redis.storage_class : "default"
  max_cpu       = var.local_redis.max_cpu != null ? var.local_redis.max_cpu : "400m"
  min_cpu       = var.local_redis.min_cpu != null ? var.local_redis.min_cpu : "200m"
  max_memory    = var.local_redis.max_memory != null ? var.local_redis.max_memory : "1.5G"
  min_memory    = var.local_redis.min_memory != null ? var.local_redis.min_memory : "1G"
}