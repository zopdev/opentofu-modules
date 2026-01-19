output "elasticache_replication_group_redis_cluster" {
  value = var.redis.num_node_groups > 1 ? aws_elasticache_replication_group.redis_cluster[0].id: ""
}

output "elasticache_replication_group_redis" {
  value =  var.redis.num_node_groups > 1? "" : aws_elasticache_replication_group.redis[0].id
}


output "elasticache_subnet_group" {
  value =  aws_elasticache_subnet_group.redis_subnets.id
}

output "redis" {
  value = var.redis != null ? {
    instance_name     = var.redis.num_node_groups > 1 ? aws_elasticache_replication_group.redis_cluster.0.replication_group_id : aws_elasticache_replication_group.redis.0.replication_group_id
    instance_url      = var.redis.num_node_groups > 1 ? aws_elasticache_replication_group.redis_cluster.0.configuration_endpoint_address : aws_elasticache_replication_group.redis.0.primary_endpoint_address
    port              = var.redis.num_node_groups > 1 ? aws_elasticache_replication_group.redis_cluster.0.port : aws_elasticache_replication_group.redis.0.port
    version           = var.redis.num_node_groups > 1 ? aws_elasticache_replication_group.redis_cluster.0.engine_version : aws_elasticache_replication_group.redis.0.engine_version
    machine_type      = var.redis.num_node_groups > 1 ? aws_elasticache_replication_group.redis_cluster.0.node_type : aws_elasticache_replication_group.redis.0.node_type
    cluster           = var.redis.num_node_groups > 1 ? aws_elasticache_replication_group.redis_cluster.0.id : ""
    security_group    = aws_security_group.redis_group.id
    redis_group       = var.redis.num_node_groups > 1 ? "" : aws_elasticache_replication_group.redis.0.id
  } : {}
}