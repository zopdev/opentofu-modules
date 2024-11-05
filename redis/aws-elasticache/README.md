# AWS Redis Terraform Module

The `redis` module contains all resources required for creating a single node REDIS cluster.

## Variables

| Inputs                  | Type         | Required/Optional | <div style="width:420px">Description</div>                                                                              | Default |
|-------------------------|--------------|-------------------|-------------------------------------------------------------------------------------------------------------------------|---------|
| engine_version          | number       | Optional          | Redis cache clusters engine version                                                                                     | `6.2`   |
| name                    | string       | Required          | Name of our redis cluster (must be less than 34 characters)                                                             |         |
| node_type               | string       | Required          | The instance class used, e.g., cache.m4.large                                                                           | `""`    |
| num_node_groups         | number       | Optional          | Number of node groups in a redis cluster (>1 enables cluster mode)                                                      | `2`     |
| redis_subnets           | list(string) | Required          | Redis subnets (contain at least 2 subnets)                                                                              |         |
| replicas_per_node_group | number       | Optional          | Number of replicas per node group with cluster mode on or number of cache clusters when cluster mode is disabled         | `2`     |
| tags                    | map(any)     | Required          | Tags for AWS resources                                                                                                  |         |
| vpc_id                  | string       | Required          | The VPC ID where the redis instance/cluster will be created                                                             |         |
