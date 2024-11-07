# Azure Redis Terraform module

The `redis` module contains all resources that is required for creating a single node REDIS cluster

## Variables

| Inputs        | Type       | Required/Optional | <div style="width:420px">Description</div>                          | Default |
|---------------|------------|-------------------|---------------------------------------------------------------------|---------|
| namespace     | string     | Required          | Namespace to which Redis instance is attached                       | `""`    |
| min_cpu       | string     | Required          | CPU request for a container                                         |         |
| max_cpu       | string     | Required          | CPU limit for a container                                           |         |
| min_memory    | string     | Required          | Memory request for a container                                      |         |
| max_memory    | string     | Required          | Memory limit for a container                                        |         |
| storage_class | string     | Required          | Persistent Volume storage class                                     |         |
| disk_size     | string     | Required          | Persistent Volume size                                              |         |