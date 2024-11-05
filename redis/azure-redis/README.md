# Azure Redis Terraform module

The `redis` module contains all resources that is required for creating a single node REDIS cluster

## Variables

| Inputs                   | Type         | Required/Optional | <div style="width:420px">Description</div>                                                                                           | Default       |
|--------------------------|--------------|-------------------|--------------------------------------------------------------------------------------------------------------------------------------|---------------|
| resource_group_name      | string       | Required          | Azure resource group name for redis                                                                                                  | `""`          |
| location                 | string       | Required          | Azure location for redis                                                                                                             | `""`          |
| name                     | string       | Required          | Name of the redis cluster                                                                                                            | `""`          |
| cache_version            | string       | Required          | The version of Redis software. For a list of available versions, please find [here](https://cloud.google.com/memorystore/docs/redis/supported-versions) | `REDIS_5_0`   |
| redis_cache_name         | string       | Required          | Redis cache Azure resource name                                                                                                      | `""`          |
| vpc_network              | string       | Required          | The VPC ID where the redis instance/cluster will be created                                                                          |               |
| sku_name                 | string       | Required          | Redis sku type                                                                                                                       | `""`          |
| sku_family               | string       | Optional          | Redis sku family                                                                                                                     | `C`           |
| sku_capacity             | string       | Optional          | Redis sku capacity                                                                                                                   | `1`           |
| redis_cache_family       | string       | Optional          | Redis family type                                                                                                                    | `""`          |
| redis_cache_capacity     | number       | Optional          | Redis Cache capacity                                                                                                                 | `2`           |
| redis_enable_non_ssl_port| bool         | Optional          | Redis access to SSL ports                                                                                                            | `false`       |
| tags                     | map(any)     | Required          | Tags for AWS resources                                                                                                               |               |