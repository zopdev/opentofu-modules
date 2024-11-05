output "primary_access_key" {
  description = "The access key of the Redis Instance"
  value       = azurerm_redis_cache.redis_cluster.primary_access_key
  sensitive   = true
}

output "redis" {
  value = var.redis != null ? {
    instance_name  = azurerm_redis_cache.redis_cluster.name
    instance_url   = azurerm_redis_cache.redis_cluster.hostname
    port           = azurerm_redis_cache.redis_cluster.port
    version        = azurerm_redis_cache.redis_cluster.redis_version
    machine_type   = azurerm_redis_cache.redis_cluster.sku_name
    family         = azurerm_redis_cache.redis_cluster.family
    memory_size    = azurerm_redis_cache.redis_cluster.capacity
    key_vault_url  = azurerm_key_vault_secret.redis_access_key.id
  } : {}
}