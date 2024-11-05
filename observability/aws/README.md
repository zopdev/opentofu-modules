# AWS Terraform  Module

The `aws` module contains all resources to set up `Loki for Logs`, `Cortex for Metrics` and `Tempo for Traces` in AWS Cloud Provider.

## Variables

| Inputs               | Type   | Required/Optional | <div style="width:450px">Description</div>                                                                           | Default |
|----------------------|--------|-------------------|----------------------------------------------------------------------------------------------------------------------|---------|
| access_key           | string | Required          | AWS IAM access key to access the S3 storage buckets                                                                  |         |
| access_secret        | string | Required          | AWS IAM access secret to access the S3 storage buckets                                                               |         |
| app_env              | string | Required          | Application deployment environment                                                                                   | `""`    |
| app_name             | string | Required          | This is the name for the project. This name is also used to namespace all the other resources created by this module |         | 
| app_region           | string | Required          | Cloud region to deploy to (e.g. us-west-2)                                                                           |         |
| cluster_name         | string | Required          | cluster_name                                                                                                         |         |
| cortex               | object | Required          | Cortex configurations that require to setup cortex                                                                   | `null`  |
| domain_name          | string | Required          | Route53 domain name for the service                                                                                  | `""`    |
| loki                 | object | Required          | Loki configurations that require to setup loki                                                                       | `""`    |       
| mimir                | object | Required          | Mimir configuration that require to setup setup                                                                       |    `""`     |
| observability_suffix | string | Required          | To add a suffix to Storage Buckets in Observability Cluster                                                          | `""`    |       
| tempo                | object | Required          | Tempo configurations that require to setup tempo                                                                     |    `""`     |


### Cortex

| <div style="width:100px">inputs</div>       | Type    | Required/Optional | <div style="width:100px">Description</div>                           | Default   |
|:--------------------------------------------|:--------|:------------------|----------------------------------------------------------------------|:----------|
| cortex.alerts.compactor_replica              | number | Optional          | Number of replicas for the Compactor component to monitor.           |         |
| cortex.alerts.distributor_replica             | number | Optional          | Number of replicas for the Distributor component to monitor.          |         |
| cortex.alerts.ingester_replica                | number | Optional          | Number of replicas for the Ingester component to monitor.             |         |
| cortex.alerts.query_frontend_replica          | number | Optional          | Number of replicas for the Query Frontend component to monitor.       |         |
| cortex.alerts.querier_replica                 | number | Optional          | Number of replicas for the Querier component to monitor.              |         |
| cortex.compactor.enable                     | boolean | Optional          | Enable the Compactor component.                                      | `true`    |
| cortex.compactor.max_cpu                    | string  | Optional          | Maximum CPU allocated for each Compactor replica.                    | `null`    |
| cortex.compactor.max_memory                 | string  | Optional          | Maximum memory allocated for each Compactor replica.                 | `null`    |
| cortex.compactor.min_cpu                    | string  | Optional          | Minimum CPU allocated for each Compactor replica.                    | `null`    |
| cortex.compactor.min_memory                 | string  | Optional          | Minimum memory allocated for each Compactor replica.                 | `null`    |
| cortex.compactor.persistence_volume.enable  | boolean | Optional          | Enable persistence volume for the Compactor.                         | `true`    |
| cortex.compactor.persistence_volume.size    | string  | Optional          | Size of the persistence volume for the Compactor.                    | `"20Gi"`  |
| cortex.compactor.replicas                   | number  | Optional          | Number of replicas for the Compactor.                                | `1`       |
| cortex.distributor.autoscaling              | boolean | Optional          | Enable autoscaling for Distributor.                                  | `true`    |
| cortex.distributor.cpu_utilization          | number  | Optional          | CPU utilization threshold for autoscaling.                           | `""`      |
| cortex.distributor.max_cpu                  | string  | Optional          | Maximum CPU allocated for each Distributor replica.                  | `null`    |
| cortex.distributor.max_memory               | string  | Optional          | Maximum memory allocated for each Distributor replica.               | `null`    |
| cortex.distributor.max_replicas             | number  | Optional          | Maximum number of replicas for the Distributor.                      | `30`      |
| cortex.distributor.memory_utilization       | number  | Optional          | Memory utilization threshold for autoscaling.                        | `""`      |
| cortex.distributor.min_cpu                  | string  | Optional          | Minimum CPU allocated for each Distributor replica.                  | `null`    |
| cortex.distributor.min_memory               | string  | Optional          | Minimum memory allocated for each Distributor replica.               | `null`    |
| cortex.distributor.min_replicas             | number  | Optional          | Minimum number of replicas for the Distributor.                      | `2`       |
| cortex.distributor.replicas                 | number  | Optional          | Number of replicas for the Distributor.                              | `1`       |
| cortex.enable                          | boolean | Required          | enable cortex for observability setup                                | `false`   |
| cortex.enable_ingress                        | boolean | Optional          | Enable ingress for Cortex observability setup.  | `false`   |
| cortex.ingester.autoscaling                 | boolean | Optional          | Enable autoscaling for Ingester.                                     | `true`    |
| cortex.ingester.max_cpu                     | string  | Optional          | Maximum CPU allocated for each Ingester replica.                     | `null`    |
| cortex.ingester.max_memory                  | string  | Optional          | Maximum memory allocated for each Ingester replica.                  | `null`    |
| cortex.ingester.max_replicas                | number  | Optional          | Maximum number of Ingester replicas during autoscaling.              | `100`     |
| cortex.ingester.memory_utilization          | number  | Optional          | Memory utilization threshold for autoscaling.                        | `""`      |
| cortex.ingester.min_cpu                     | string  | Optional          | Minimum CPU allocated for each Ingester replica.                     | `null`    |
| cortex.ingester.min_memory                  | string  | Optional          | Minimum memory allocated for each Ingester replica.                  | `null`    |
| cortex.ingester.persistence_volume.size     | string  | Optional          | Size of the persistence volume for the for ingester.                 | `20Gi`    |
| cortex.ingester.min_replicas                | number  | Optional          | Minimum number of Ingester replicas during autoscaling.              | `2`       |
| cortex.ingester.replicas                    | number  | Optional          | Number of replicas for the Ingester.                                 | `1`       |
| cortex.limits.ingestion_burst_size          | number  | Optional          | Maximum burst size for ingestion.                                    | `500000`  |
| cortex.limits.ingestion_rate                | number  | Optional          | Maximum ingestion rate.                                              | `250000`  |
| cortex.limits.max_fetched_chunks_per_query  | number  | Optional          | Maximum fetched chunks p er query (0 for unlimited).                 | `3000000` |
| cortex.limits.max_series_per_metric         | number  | Optional          | Maximum series per metric (0 for unlimited).                         | `0`       |
| cortex.limits.max_series_per_user           | number  | Optional          | Maximum series per user (0 for unlimited).                           | `0`       |
| cortex.memcached_blocks.enable              | boolean | Optional          | Enable the Memcached Blocks component.                               | `true`    |
| cortex.memcached_blocks.max_cpu             | string  | Optional          | Maximum CPU allocated for each Memcached Blocks replica.             | `null`    |
| cortex.memcached_blocks.max_memory          | string  | Optional          | Maximum memory allocated for each Memcached Blocks replica.          | `null`    |
| cortex.memcached_blocks.min_cpu             | string  | Optional          | Minimum CPU allocated for each Memcached Blocks replica.             | `null`    |
| cortex.memcached_blocks.min_memory          | string  | Optional          | Minimum memory allocated for each Memcached Blocks replica.          | `null`    |
| cortex.memcached_blocks_index.enable        | boolean | Optional          | Enable the Memcached Blocks Index component.                         | `true`    |
| cortex.memcached_blocks_index.max_cpu       | string  | Optional          | Maximum CPU allocated for each Memcached Blocks Index replica.       | `null`    |
| cortex.memcached_blocks_index.max_memory    | string  | Optional          | Maximum memory allocated for each Memcached Blocks Index replica.    | `null`    |
| cortex.memcached_blocks_index.min_cpu       | string  | Optional          | Minimum CPU allocated for each Memcached Blocks Index replica.       | `null`    |
| cortex.memcached_blocks_index.min_memory    | string  | Optional          | Minimum memory allocated for each Memcached Blocks Index replica.    | `null`    |
| cortex.memcached_blocks_metadata.enable     | boolean | Optional          | Enable the Memcached Blocks Metadata component.                      | `true`    |
| cortex.memcached_blocks_metadata.max_cpu    | string  | Optional          | Maximum CPU allocated for each Memcached Blocks Metadata replica.    | `null`    |
| cortex.memcached_blocks_metadata.max_memory | string  | Optional          | Maximum memory allocated for each Memcached Blocks Metadata replica. | `null`    |
| cortex.memcached_blocks_metadata.min_cpu    | string  | Optional          | Minimum CPU allocated for each Memcached Blocks Metadata replica.    | `null`    |
| cortex.memcached_blocks_metadata.min_memory | string  | Optional          | Minimum memory allocated for each Memcached Blocks Metadata replica. | `null`    |
| cortex.memcached_frontend.enable            | boolean | Optional          | Enable the Memcached Frontend component.                             | `true`    |
| cortex.memcached_frontend.max_cpu           | string  | Optional          | Maximum CPU allocated for each Memcached Frontend replica.           | `null`    |
| cortex.memcached_frontend.max_memory        | string  | Optional          | Maximum memory allocated for each Memcached Frontend replica.        | `null`    |
| cortex.memcached_frontend.min_cpu           | string  | Optional          | Minimum CPU allocated for each Memcached Frontend replica.           | `null`    |
| cortex.memcached_frontend.min_memory        | string  | Optional          | Minimum memory allocated for each Memcached Frontend replica.        | `null`    |
| cortex.querier.autoscaling                  | boolean | Optional          | Enable autoscaling for Querier.                                      | `true`    |
| cortex.querier.cpu_utilization              | number  | Optional          | CPU utilization threshold for autoscaling.                           | `""`      |
| cortex.querier.max_cpu                      | string  | Optional          | Maximum CPU allocated for each Querier replica.                      | `null`    |
| cortex.querier.max_memory                   | string  | Optional          | Maximum memory allocated for each Querier replica.                   | `null`    |
| cortex.querier.max_replicas                 | number  | Optional          | Maximum number of Querier replicas during autoscaling.               | `20`      |
| cortex.querier.memory_utilization           | number  | Optional          | Memory utilization threshold for autoscaling.                        | `""`      |
| cortex.querier.min_cpu                      | string  | Optional          | Minimum CPU allocated for each Querier replica.                      | `null`    |
| cortex.querier.min_memory                   | string  | Optional          | Minimum memory allocated for each Querier replica.                   | `null`    |
| cortex.querier.min_replicas                 | number  | Optional          | Minimum number of Querier replicas during autoscaling.               | `2`       |
| cortex.querier.replicas                     | number  | Optional          | Number of replicas for the Querier.                                  | `1`       |
| cortex.query_frontend.enable                | boolean | Optional          | Enable the Query Frontend component.                                 | `true`    |
| cortex.query_frontend.replicas              | number  | Optional          | Number of replicas for the Query Frontend.                           | `4`       |
| cortex.query_range.memcached_client_timeout | string  | Optional          | query range memcached_client_timeout                                 | `"30s"`   |
| cortex.storegateway.min_memory              | string  | Optional          | Minimum memory allocated for each Store Gateway replica.             | `null`    | 
| cortex.storegateway.min_cpu                 | string  | Optional          | Minimum CPU allocated for each Store Gateway replica.                | `null`    | 
| cortex.storegateway.max_memory              | string  | Optional          | Maximum memory allocated for each Store Gateway replica.             | `null`    |
| cortex.storegateway.max_cpu                 | string  | Optional          | Maximum CPU allocated for each Store Gateway replica.                | `null`    |
| cortex.storegateway.persistence_volume.size | string  | Optional          | Size of the persistence volume for the Store Gateway.                | `"500Gi"` |
| cortex.storegateway.replicas                | number  | Optional          | Number of replicas for the Store Gateway.                            | `1`       | 
| cortex.storegateway.replication_factor      | number  | Optional          | Replication factor for the Store Gateway.                            | `3`       | 


### Loki

| inputs                                | Type    | Required/Optional | <div style="width:400px">Description</div>                   | Default |
|---------------------------------------|---------|-------------------|--------------------------------------------------------------|---------|
| loki.alerts.compactor_replica                | number | Optional          | Number of compactor replicas to monitor.             |         |
| loki.alerts.distributor_appended_failures     | number | Optional          | Number of failures when appending logs to the distributor. |         |
| loki.alerts.distributor_bytes_received        | number | Optional          | Total bytes received by the distributor.             |         |
| loki.alerts.distributor_lines_received        | string | Optional          | Total lines received by the distributor.             |         |
| loki.alerts.distributor_replica               | number | Optional          | Number of distributor replicas to monitor.           |         |
| loki.alerts.ingester_replica                  | number | Optional          | Number of ingester replicas to monitor.              |         |
| loki.alerts.panics                           | number | Optional          | Number of panic incidents reported.                  |         |
| loki.alerts.query_frontend_replica            | number | Optional          | Number of query frontend replicas to monitor.        |         |
| loki.alerts.querier_replica                   | number | Optional          | Number of querier replicas to monitor.               |         |
| loki.alerts.request_errors                    | number | Optional          | Number of request errors reported.                   |         |
| loki.alerts.request_latency                   | number | Optional          | Latency of requests in milliseconds.                  |         |
| loki.distributor.autoscaling          | boolean | Optional          | Enable autoscaling for Distributor.                          | `true`  |
| loki.distributor.autoscaling              | boolean | Optional          | Enable autoscaling for Distributor.                                  |     |
| loki.distributor.cpu_utilization      | number  | Optional          | CPU utilization threshold for autoscaling.                   | `""`    |
| loki.distributor.max_cpu              | string  | Optional          | Maximum CPU allocated for each Distributor replica.          | `1`     |
| loki.distributor.max_memory           | string  | Optional          | Maximum memory allocated for each Distributor replica.       | `1Gi`   |
| loki.distributor.max_replicas         | number  | Optional          | Maximum number of Distributor replicas during autoscaling.   | `30`    |
| loki.distributor.memory_utilization   | number  | Optional          | Memory utilization threshold for autoscaling.                | `""`    |
| loki.distributor.min_cpu              | string  | Optional          | Minimum CPU allocated for each Distributor replica.          | `250m`  |
| loki.distributor.min_memory           | string  | Optional          | Minimum memory allocated for each Distributor replica.       | `512Mi` |
| loki.distributor.min_replicas         | number  | Optional          | Minimum number of Distributor replicas during autoscaling.   | `2`     |
| loki.distributor.replicas             | number  | Optional          | Number of replicas for the Distributor.                      | `1`     |
| loki.enable | boolean | Required          | enable loki for observability setup                          | `false` |
| loki.enable_ingress       | boolean | Optional          | Enable or disable ingress for Loki. |  |
| loki.ingester.autoscaling             | boolean | Optional          | Enable autoscaling for Ingester.                             | `true`  |
| loki.ingester.cpu_utilization         | number  | Optional          | CPU utilization threshold for autoscaling.                   | `""`    |
| loki.ingester.max_cpu                 | string  | Optional          | Maximum CPU allocated for each Ingester replica.             | `null`  |
| loki.ingester.max_memory              | string  | Optional          | Maximum memory allocated for each Ingester replica.          | `2Gi`   |
| loki.ingester.max_replicas            | number  | Optional          | Maximum number of Ingester replicas during autoscaling.      | `30`    |
| loki.ingester.memory_utilization      | number  | Optional          | Memory utilization threshold for autoscaling.                | `""`    |
| loki.ingester.min_cpu                 | string  | Optional          | Minimum CPU allocated for each Ingester replica.             | `null`  |
| loki.ingester.min_memory              | string  | Optional          | Minimum memory allocated for each Ingester replica.          | `1Gi`   |
| loki.ingester.min_replicas            | number  | Optional          | Minimum number of Ingester replicas during autoscaling.      | `2`     |
| loki.ingester.replicas                | number  | Optional          | Number of replicas for the Ingester.                         | `1`     |
| loki.querier.autoscaling              | boolean | Optional          | Enable autoscaling for Querier.                              | `true`  |
| loki.querier.cpu_utilization          | number  | Optional          | CPU utilization threshold for autoscaling.                   | `""`    |
| loki.querier.max_cpu                  | string  | Optional          | Maxmum CPU allocated for each Querier replica.               | `null`  |
| loki.querier.max_memory               | string  | Optional          | Maxmum memory allocated for each Querier replica.            | `null`  |
| loki.querier.max_replicas             | number  | Optional          | Maximum number of Querier replicas during autoscaling.       | `6`     |
| loki.querier.memory_utilization       | number  | Optional          | Memory utilization threshold for autoscaling.                | `""`    |
| loki.querier.min_cpu                  | string  | Optional          | Minimum CPU allocated for each Querier replica.              | `100m`  |
| loki.querier.min_memory               | string  | Optional          | Minimum memory allocated for each Querier replica.           | `500Mi` |
| loki.querier.min_replicas             | number  | Optional          | Minimum number of Querier replicas during autoscaling.       | `2`     |
| loki.querier.replicas                 | number  | Optional          | Number of replicas for the Querier.                          | `4`     |
| loki.querier.max_unavailable          | number  | Optional          | Maximum unavailable replicas for the Querier.                | `1`     |
| loki.queryfrontend.autoscaling        | boolean | Optional          | Enable autoscaling for QueryFrontend.                        | `true`  |
| loki.queryfrontend.cpu_utilization    | number  | Optional          | CPU utilization threshold for autoscaling.                   | `""`    |
| loki.queryfrontend.max_cpu            | string  | Optional          | Maximum CPU allocated for each queryfrontend replica.        | `null`  |
| loki.queryfrontend.max_memory         | string  | Optional          | Maximummemory allocated for each queryfrontend replica.      | `null`  |
| loki.queryfrontend.max_replicas       | number  | Optional          | Maximum number of QueryFrontend replicas during autoscaling. | `6`     |
| loki.queryfrontend.memory_utilization | number  | Optional          | Memory utilization threshold for autoscaling.                | `""`    |
| loki.queryfrontend.min_cpu            | string  | Optional          | Minimum CPU allocated for each queryfrontend replica.        | `null`  |
| loki.queryfrontend.min_memory         | string  | Optional          | Minimum memory allocated for each queryfrontend replica.     | `250Mi` |
| loki.queryfrontend.min_replicas       | number  | Optional          | Minimum number of QueryFrontend replicas during autoscaling. | `1`     |
| loki.queryfrontend.replicas           | number  | Optional          | Number of replicas for the QueryFrontend.                    | `1`     |

### Mimir

| Inputs                                          | Type         | Required/Optional | <div style="width:450px">Description</div>                                           | Default |
|-------------------------------------------------|--------------|-------------------|----------------------------------------------------------------------------------------|---------|
| mimir.alerts.compactor_replica                 | number | Optional          | Number of compactor replicas.                                                   |         |
| mimir.alerts.distributor_appended_failures      | number | Optional          | Number of failures in distributor appends.                                       |         |
| mimir.alerts.distributor_bytes_received         | number | Optional          | Number of bytes received by the distributor.                                     |         |
| mimir.alerts.distributor_lines_received         | string | Optional          | Number of lines received by the distributor.                                     |         |
| mimir.alerts.distributor_replica                | number | Optional          | Number of distributor replicas.                                                   |         |
| mimir.alerts.ingester_replica                   | number | Optional          | Number of ingester replicas.                                                       |         |
| mimir.alerts.panics                             | number | Optional          | Number of panic events.                                                             |         |
| mimir.alerts.query_frontend_replica             | number | Optional          | Number of query frontend replicas.                                                |         |
| mimir.alerts.querier_replica                    | number | Optional          | Number of querier replicas.                                                        |         |
| mimir.alerts.request_errors                     | number | Optional          | Number of request errors.                                                           |         |
| mimir.alerts.request_latency                    | number | Optional          | Latency of requests in the system.                                                 |         |
| mimir.compactor.max_cpu                         | string       | Optional          | Maximum CPU allocated for each Compactor replica.                                    | null    |
| mimir.compactor.max_memory                      | string       | Optional          | Maximum memory allocated for each Compactor replica.                                 | null    |
| mimir.compactor.min_cpu                         | string       | Optional          | Minimum CPU allocated for each Compactor replica.                                    | null    |
| mimir.compactor.min_memory                      | string       | Optional          | Minimum memory allocated for each Compactor replica.                                 | null    |
| mimir.compactor.persistence_volume.enable       | bool         | Optional          | Enable persistence volume for the Compactor.                                         | true    |
| mimir.compactor.persistence_volume.size         | string       | Optional          | Size of the persistence volume for the Compactor.                                    | "20Gi"  |
| mimir.compactor.replicas                        | number       | Optional          | Number of replicas for the Compactor.                                                 | 1       |
| mimir.distributor.max_cpu                       | string       | Optional          | Maximum CPU allocated for each Distributor replica.                                   | null    |
| mimir.distributor.max_memory                    | string       | Optional          | Maximum memory allocated for each Distributor replica.                                | null    |
| mimir.distributor.min_cpu                       | string       | Optional          | Minimum CPU allocated for each Distributor replica.                                   | null    |
| mimir.distributor.min_memory                    | string       | Optional          | Minimum memory allocated for each Distributor replica.                                | null    |
| mimir.distributor.replicas                      | number       | Optional          | Number of replicas for the Distributor.                                               |         |
| mimir.enable                                   | bool         | Required          | Enable mimir for observability setup.                                                  | false   |
| mimir.enable_ingress                           | bool   | Optional          | Enable ingress for Mimir.                                                             | `false` |
| mimir.ingester.max_cpu                          | string       | Optional          | Maximum CPU allocated for each Ingester replica.                                      | null    |
| mimir.ingester.max_memory                       | string       | Optional          | Maximum memory allocated for each Ingester replica.                                   | null    |
| mimir.ingester.min_cpu                          | string       | Optional          | Minimum CPU allocated for each Ingester replica.                                      | null    |
| mimir.ingester.min_memory                       | string       | Optional          | Minimum memory allocated for each Ingester replica.                                   | null    |
| mimir.ingester.persistence_volume.size          | string       | Optional          | Size of the persistence volume for the Ingester.                                      | null    |
| mimir.ingester.replicas                         | number       | Optional          | Number of replicas for the Ingester.                                                   |         |
| mimir.limits.ingestion_burst_size               | number       | Optional          | Maximum burst size for ingestion.                                                     |         |
| mimir.limits.ingestion_rate                    | number       | Optional          | Ingestion rate limit.                                                                  |         |
| mimir.limits.max_cache_freshness                | number       | Optional          | Maximum freshness of cached data.                                                      |         |
| mimir.limits.max_fetched_chunks_per_query       | number       | Optional          | Maximum number of chunks fetched per query.                                           |         |
| mimir.limits.max_outstanding_requests_per_tenant | number       | Optional          | Maximum outstanding requests per tenant.                                              |         |
| mimir.querier.max_cpu                           | string       | Optional          | Maximum CPU allocated for each Querier replica.                                       | null    |
| mimir.querier.max_memory                        | string       | Optional          | Maximum memory allocated for each Querier replica.                                    | null    |
| mimir.querier.min_cpu                           | string       | Optional          | Minimum CPU allocated for each Querier replica.                                       | null    |
| mimir.querier.min_memory                        | string       | Optional          | Minimum memory allocated for each Querier replica.                                    | null    |
| mimir.querier.replicas                          | number       | Optional          | Number of replicas for the Querier.                                                    |         |
| mimir.query_frontend.replicas                   | number       | Optional          | Number of replicas for the Query Frontend.                                             |         |
| mimir.store_gateway.max_cpu                     | string       | Optional          | Maximum CPU allocated for each Store Gateway replica.                                 | null    |
| mimir.store_gateway.max_memory                  | string       | Optional          | Maximum memory allocated for each Store Gateway replica.                              | null    |
| mimir.store_gateway.min_cpu                     | string       | Optional          | Minimum CPU allocated for each Store Gateway replica.                                 | null    |
| mimir.store_gateway.min_memory                  | string       | Optional          | Minimum memory allocated for each Store Gateway replica.                              | null    |
| mimir.store_gateway.persistence_volume.size     | string       | Optional          | Size of the persistence volume for the Store Gateway.                                 | null    |
| mimir.store_gateway.replicas                    | number       | Optional          | Number of replicas for the Store Gateway.                                              |         |
| mimir.store_gateway.replication_factor          | number       | Optional          | Replication factor for the Store Gateway.                                              |         |


### Tempo

| inputs                                                     | Type         | Required/Optional | <div style="width:400px">Description</div>                 | Default |
|------------------------------------------------------------|--------------|-------------------|------------------------------------------------------------|---------|
| tempo.alerts.compactor_replica                            | number | Optional          | Number of compactor replicas to alert on.                                             |         |
| tempo.alerts.distributor_bytes_received                     | number | Optional          | Number of bytes received by the distributor to alert on.                                |         |
| tempo.alerts.distributor_ingester_append_failures           | number | Optional          | Number of ingester append failures reported by the distributor.                         |         |
| tempo.alerts.distributor_ingester_appends                   | number | Optional          | Number of ingester appends reported by the distributor.                                  |         |
| tempo.alerts.distributor_replica                            | number | Optional          | Number of distributor replicas to alert on.                                              |         |
| tempo.alerts.distributor_spans_received                     | number | Optional          | Number of spans received by the distributor to alert on.                                 |         |
| tempo.alerts.ingester_blocks_flushed                        | number | Optional          | Number of blocks flushed by the ingester to alert on.                                     |         |
| tempo.alerts.ingester_bytes_received                        | number | Optional          | Number of bytes received by the ingester to alert on.                                     |         |
| tempo.alerts.ingester_live_traces                           | number | Optional          | Number of live traces reported by the ingester to alert on.                              |         |
| tempo.alerts.ingester_replica                               | number | Optional          | Number of ingester replicas to alert on.                                                 |         |
| tempo.alerts.query_frontend_replica                         | number | Optional          | Number of query frontend replicas to alert on.                                            |         |
| tempo.alerts.querier_replica                                | number | Optional          | Number of querier replicas to alert on.                                                  |         |
| tempo.alerts.tempodb_blocklist                              | number | Optional          | Number of tempodb blocklist entries to alert on.                                         |         |
| tempo.distributor.autoscaling                              | boolean      | Optional          | Enable autoscaling for Distributor.                        | `true`  |
| tempo.distributor.cpu_utilization                          | number       | Optional          | CPU utilization threshold for autoscaling.                 | `""`    |
| tempo.distributor.max_cpu                                  | string       | Optional          | Maximum CPU allocated for each Distributor replica.        | `null`  |
| tempo.distributor.max_memory                               | string       | Optional          | Maximum memory allocated for each Distributor replica.     | `null`  |
| tempo.distributor.max_replicas                             | number       | Optional          | Maximum number of Distributor replicas during autoscaling. | `30`    |
| tempo.distributor.memory_utilization                       | number       | Optional          | Memory utilization threshold for autoscaling.              | `""`    |
| tempo.distributor.min_cpu                                  | string       | Optional          | Minimum CPU allocated for each Distributor replica.        | `null`  |
| tempo.distributor.min_memory                               | string       | Optional          | Minimum memory allocated for each Distributor replica.     | `750Mi` |
| tempo.distributor.min_replicas                             | number       | Optional          | Minimum number of Distributor replicas during autoscaling. | `2`     |
| tempo.distributor.replicas                                 | number       | Optional          | Number of replicas for the Distributor.                    | `1`     |
| tempo.enable                                               | boolean      | Required          | enable tempo for observability setup                       | `false` |
| tempo.enable_ingress                           | boolean | Optional          | Enable ingress for Tempo.  | `false` |
| tempo.ingester.autoscaling                                 | boolean      | Optional          | Enable autoscaling for Ingester.                           | `true`  |
| tempo.ingester.cpu_utilization                             | number       | Optional          | CPU utilization threshold for autoscaling.                 | `""`    |
| tempo.ingester.max_cpu                                     | string       | Optional          | Maximum CPU allocated for each Ingester replica.           | `null`  |
| tempo.ingester.max_memory                                  | string       | Optional          | Maximum memory allocated for each Ingester replica.        | `null`  |
| tempo.ingester.max_replicas                                | number       | Optional          | Maximum number of Ingester replicas during autoscaling.    | `30`    |
| tempo.ingester.memory_utilization                          | number       | Optional          | Memory utilization threshold for autoscaling.              | `""`    |
| tempo.ingester.min_cpu                                     | string       | Optional          | Minimum CPU allocated for each Ingester replica.           | `null`  |
| tempo.ingester.min_memory                                  | string       | Optional          | Minimum memory allocated for each Ingester replica.        | `1Gi`   |
| tempo.ingester.min_replicas                                | number       | Optional          | Minimum number of Ingester replicas during autoscaling.    | `2`     |
| tempo.ingester.replicas                                    | number       | Optional          | Number of replicas for the Ingester.                       | `1`     |
| tempo.metrics_generator.enable                             | bool         | Optional          | Enable metrics generator for tempo datasource              | `false` |
| tempo.metrics_generator.metrics_ingestion_time_range_slack | string       | Optional          | Metrics ingestion time range slack                         | `40s`   |
| tempo.metrics_generator.remote_write                       | list(object) | Optional          | Prometheus remote write configs for service graph metrics  | `null`  |
| tempo.metrics_generator.remote_write.flush_deadline        | string       | Optional          | Remote write storage flush deadline                        | `2m`    |
| tempo.metrics_generator.remote_write.header                | object       | Required          | Header needed for storage remote write                     | `null`  |
| tempo.metrics_generator.remote_write.header.key            | string       | Required          | Header key needed for storage remote write                 | `null`  |
| tempo.metrics_generator.remote_write.header.value          | string       | Required          | Header value needed for storage remote write               | `null`  |
| tempo.metrics_generator.remote_write.host                  | string       | Required          | host(url) of storage remote write                          | `null`  |
| tempo.metrics_generator.replicas                           | number       | Optional          | Number of replicas for the metrics generator.              | `1`     |
| tempo.metrics_generator.service_graphs_max_items           | number       | Optional          | Minimum memory allocated for each Ingester replica.        | `30000` |
| tempo.metrics_generator.service_graphs_wait                | string       | Optional          | Minimum number of Ingester replicas during autoscaling.    | `30s`   |
| tempo.querier.replicas                                     | number       | Optional          | Number of replicas for the Querier.                        | `1`     |
| tempo.query_frontend.replicas                               | number       | Optional          | Number of replicas for the Query Frontend.                 | `1`     |