# GCP Redis Terraform module

The `redis` module contains all resources that is required for creating a single node REDIS cluster

## Variables

| Inputs                  | Type         | Required/Optional | <div style="width:420px">Description</div>                                                                                           | Default           |
|-------------------------|--------------|-------------------|--------------------------------------------------------------------------------------------------------------------------------------|-------------------|
| project                 | string       | Required          | The project ID to host the database in.                                                                                              | `""`              |
| name                    | string       | Required          | Name of the redis cluster (must be less than 34 characters)                                                                          |              |
| replica_count           | number       | Required          | Number of replica nodes in a redis cluster (>1 enables cluster mode).                                                                |                   |
| machine_type            | string       | Optional          | The type of the tier that the redis use.                                                                                             | `BASIC`           |
| memory_size_gb          | number       | Optional          | Size of the redis in GB                                                                                                              | `1`               |
| connect_mode            | string       | Optional          | The connection mode of the Redis instance. Can be either DIRECT_PEERING or PRIVATE_SERVICE_ACCESS. Default is 'DIRECT_PEERING'.       | `DIRECT_PEERING`  |
| region                  | string       | Required          | The region to host the database in.                                                                                                  | `""`              |
| redis_version           | string       | Required          | The version of Redis software. For a list of available versions, please find [here](https://cloud.google.com/memorystore/docs/redis/supported-versions) | `REDIS_5_0`       |
| vpc_network             | string       | Required          | The VPC ID where the redis instance/cluster will be created.                                                                         |                   |
| labels                  | map(string)  | Optional          | Common Labels on the resources                                                                                                       |                   |