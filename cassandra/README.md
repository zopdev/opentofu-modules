# Cassandra Terraform Module

The `cassandra` module contains all the resources required for deploying cassandra to our cluster.

## Variables

| Inputs             | Type   | Required/Optional | <div style="width:400px">Description</div>    | Default |
|--------------------|--------|-------------------|-----------------------------------------------|---------|
| admin_user         | string | Required          | Username for cassandra                        |         |
| cassandra_password | string | Required          | Password for cassandra                        |         |
| name               | string | Required          | Name for cassandra database                   |         |
| persistence_size   | number | Optional          | PVC Storage Request for Cassandra data volume | `10`    |
| replica_count      | number | Optional          | Number of Cassandra replicas                  | `1`     |
