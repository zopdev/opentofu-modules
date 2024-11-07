# Redis
The `redis` module contains all resources that is required for creating a REDIS cluster

## gcp-redis

 `google_compute_firewall`
- Each network has its own firewall controlling access to and from the instances.
- All traffic to instances, even from other instances, is blocked by the firewall unless firewall rules are created to allow it.

`google_redis_instance`
- A google_redis_instance is used to test a Google Instance resource

## aws-elasticache
 `aws_vpc`
- Provides a VPC resource.

 `aws_security_group`
- Provides a security group resource.

`aws_elasticache_replication_group`
- Provides an ElastiCache Replication Group resource.
 
`aws_elasticache_subnet_group`
- Provides information about a ElastiCache Subnet Group.

## azure-redis
 `azurerm_virtual_network`
- Manages a virtual network including any configured subnets. Each subnet can optionally be configured with a security group to be associated with the subnet.

`azurerm_subnet`
- Manages a subnet. Subnets represent network segments within the IP space defined by the virtual network.

`azurerm_redis_cache`
- Manages a Redis Cache.
