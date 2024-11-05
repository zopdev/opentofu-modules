# GCP Terraform  Module

The `gcp` module contains all resources to setup `Loki for Logs`, `Cortex for Metrics` and `Tempo for Traces` in Google Cloud Provider.

## Variables

| Inputs                      | Type        | Required/Optional | <div style="width:450px">Description</div>                                                                           | Default |
|-----------------------------|-------------|-------------------|----------------------------------------------------------------------------------------------------------------------|---------|
| app_env                     | string      | Required          | Application deployment environment                                                                                   | `""`    |
| app_name                    | string      | Required          | This is the name for the project. This name is also used to namespace all the other resources created by this module |         |
| app_region                  | string      | Required          | Cloud region to deploy to (e.g. us-east1)                                                                            |         |
| cortex                      | object      | Required          | Cortex configuration for observability setup                                                                   | `null`  |
| domain_name                 | string      | Required          | Cloud DNS host name for the service                                                                                  | `""`    |
| hosted_zone                 | string      | Required          | Hosted zone name for the records                                                                                     | `""`    |
| labels                      | map(string) | Required          | Common Labels on the resources                                                                                       | `null`  |
| loki                        | object      | Required          | Loki configuration for observability setup                                                                       | `""`    |
| mimir                       | object      | Required          | mimir configuration for observability setup                                                                      | `null`  |
| observability_suffix        | string      | Required          | To add a suffix to Storage Buckets in Observability Cluster                                                          | `""`    |       
| project_id                  | string      | Required          | Project ID                                                                                                           | `""`    |
| service_account_name_prefix | string      | Required          | Prefix to be used for Service Account Names                                                                         |         |
| tempo                       | object      | Required          | tempo configuration for observability setup                                                                     | `""`    |                                                                     |         |

### Cortex

| <div style="width:100px">inputs</div>       | Type    | Required/Optional | <div style="width:100px">Description</div>                           | Default   |
|:--------------------------------------------|:--------|:------------------|----------------------------------------------------------------------|:----------|
| cortex.alerts.compactor_replica | number | Optional | Number of replicas for the Compactor component. | |
| cortex.alerts.distributor_replica | number | Optional | Number of replicas for the Distributor component. | |
| cortex.alerts.ingester_replica | number | Optional | Number of replicas for the Ingester component. | |
| cortex.alerts.query_frontend_replica | number | Optional | Number of replicas for the Query Frontend component. | |
| cortex.alerts.querier_replica | number | Optional | Number of replicas for the Querier component. | |
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
| cortex.enable_ingress                               | boolean | Optional          |Enable or disable the ingress for Cortex components.                            |   |
| cortex.ingester.autoscaling                 | boolean | Optional          | Enable autoscaling for Ingester.                                     | `true`    |
| cortex.ingester.max_cpu                     | string  | Optional          | Maximum CPU allocated for each Ingester replica.                     | `null`    |
| cortex.ingester.max_memory                  | string  | Optional          | Maximum memory allocated for each Ingester replica.                  | `null`    |
| cortex.ingester.max_replicas                | number  | Optional          | Maximum number of Ingester replicas during autoscaling.              | `100`     |
| cortex.ingester.memory_utilization          | number  | Optional          | Memory utilization threshold for autoscaling.                        | `""`      |
| cortex.ingester.min_cpu                     | string  | Optional          | Minimum CPU allocated for each Ingester replica.                     | `null`    |
| cortex.ingester.min_memory                  | string  | Optional          | Minimum memory allocated for each Ingester replica.                  | `null`    |
| cortex.ingester.min_replicas                | number  | Optional          | Minimum number of Ingester replicas during autoscaling.              | `2`       |
| cortex.ingester.persistence_volume.size     | string  | Optional          | Size of the persistence volume for the Ingester.                     | `20Gi`    |
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
| loki.alerts.compactor_replica             | number | Optional          | Number of replicas for the Compactor component.                                        |         |
| loki.alerts.distributor_appended_failures | number | Optional          | Number of failed append operations in the Distributor component.                        |         |
| loki.alerts.distributor_bytes_received    | number | Optional          | Total bytes received by the Distributor component.                                      |         |
| loki.alerts.distributor_lines_received    | string | Optional          | Total number of lines received by the Distributor component.                            |         |
| loki.alerts.distributor_replica           | number | Optional          | Number of replicas for the Distributor component.                                       |         |
| loki.alerts.ingester_replica              | number | Optional          | Number of replicas for the Ingester component.                                          |         |
| loki.alerts.panics                        | number | Optional          | Number of panic incidents within the Loki components.                                   |         |
| loki.alerts.query_frontend_replica        | number | Optional          | Number of replicas for the Query Frontend component.                                    |         |
| loki.alerts.querier_replica               | number | Optional          | Number of replicas for the Querier component.                                           |         |
| loki.alerts.request_errors                | number | Optional          | Number of request errors encountered by Loki components.                                |         |
| loki.alerts.request_latency               | number | Optional          | Latency of requests processed by Loki components.                                       |         |
| loki.distributor.autoscaling          | boolean | Optional          | Enable autoscaling for Distributor.                          | `true`  |
| loki.distributor.cpu_utilization      | number  | Optional          | CPU utilization threshold for autoscaling.                   | `""`    |
| loki.distributor.max_cpu              | string  | Optional          | Maximum CPU allocated for each Distributor replica.          | `1`     |
| loki.distributor.max_memory           | string  | Optional          | Maximum memory allocated for each Distributor replica.       | `1Gi`   |
| loki.distributor.max_replicas         | number  | Optional          | Maximum number of Distributor replicas during autoscaling.   | `30`    |
| loki.distributor.memory_utilization   | number  | Optional          | Memory utilization threshold for autoscaling.                | `""`    |
| loki.distributor.min_cpu              | string  | Optional          | Minimum CPU allocated for each Distributor replica.          | `250m`  |
| loki.distributor.min_memory           | string  | Optional          | Minimum memory allocated for each Distributor replica.       | `512Mi` |
| loki.distributor.min_replicas         | number  | Optional          | Minimum number of Distributor replicas during autoscaling.   | `2`     |
| loki.distributor.replicas             | number  | Optional          | Number of replicas for the Distributor.                      | `1`     |
| loki.enable                           | boolean | Required          | enable loki for observability setup                          | `false` |
| loki.enable_ingress                           | boolean | Optional          |  Enable or disable the ingress for loki components.                          | |
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

| Input Name                                            | Type         | Required/Optional | Description                                  | Default |
|-------------------------------------------------------|--------------|-------------------|----------------------------------------------|---------|
| mimir.alerts.compactor_replica                       | number | Optional          | Number of replicas for the Compactor component.                                        |         |
| mimir.alerts.distributor_replica                      | number | Optional          | Number of replicas for the Distributor component.                                       |         |
| mimir.alerts.ingester_replica                         | number | Optional          | Number of replicas for the Ingester component.                                          |         |
| mimir.alerts.query_frontend_replica                   | number | Optional          | Number of replicas for the Query Frontend component.                                    |         |
| mimir.alerts.querier_replica                          | number | Optional          | Number of replicas for the Querier component.                                           |         |
| mimir.compactor.max_cpu                               | string       | Optional          | Maximum CPU allocated for Compactor          |         |
| mimir.compactor.max_memory                            | string       | Optional          | Maximum memory allocated for Compactor       |         |
| mimir.compactor.min_cpu                               | string       | Optional          | Minimum CPU allocated for Compactor          |         |
| mimir.compactor.min_memory                            | string       | Optional          | Minimum memory allocated for Compactor       |         |
| mimir.compactor.persistence_volume.enable            | boolean      | Optional          | Enable persistence volume for Compactor      |         |
| mimir.compactor.persistence_volume.size              | string       | Optional          | Size of the persistence volume for Compactor |         |
| mimir.compactor.replicas                             | number       | Optional          | Number of replicas for Compactor             |         |
| mimir.distributor.max_cpu                             | string       | Optional          | Maximum CPU allocated for Distributor         |         |
| mimir.distributor.max_memory                          | string       | Optional          | Maximum memory allocated for Distributor      |         |
| mimir.distributor.min_cpu                             | string       | Optional          | Minimum CPU allocated for Distributor         |         |
| mimir.distributor.min_memory                          | string       | Optional          | Minimum memory allocated for Distributor      |         |
| mimir.distributor.replicas                            | number       | Optional          | Number of replicas for Distributor            |         |
| mimir.enable                                         | boolean      | Required          | Enable Mimir configuration                    |         |
| mimir.enable_ingress                                 | boolean      | Optional          |                 Enable or disable the ingress for mimir components                             |         |
| mimir.limits.ingestion_burst_size                     | number       | Optional          | Ingestion burst size for Mimir                |         |
| mimir.limits.ingestion_rate                           | number       | Optional          | Ingestion rate for Mimir                     |         |
| mimir.limits.max_cache_freshness                      | number       | Optional          | Maximum cache freshness for Mimir            |         |
| mimir.limits.max_fetched_chunks_per_query             | number       | Optional          | Maximum fetched chunks per query for Mimir   |         |
| mimir.limits.max_outstanding_requests_per_tenant      | number       | Optional          | Maximum outstanding requests per tenant for Mimir |         |
| mimir.ingester.max_cpu                                | string       | Optional          | Maximum CPU allocated for Ingester           |         |
| mimir.ingester.max_memory                             | string       | Optional          | Maximum memory allocated for Ingester        |         |
| mimir.ingester.min_cpu                                | string       | Optional          | Minimum CPU allocated for Ingester           |         |
| mimir.ingester.min_memory                             | string       | Optional          | Minimum memory allocated for Ingester        |         |
| mimir.ingester.persistence_volume.size                | string       | Optional          | Size of the persistence volume for Ingester  |         |
| mimir.ingester.replicas                               | number       | Optional          | Number of replicas for Ingester              |         |
| mimir.querier.max_cpu                                 | string       | Optional          | Maximum CPU allocated for Querier            |         |
| mimir.querier.max_memory                              | string       | Optional          | Maximum memory allocated for Querier         |         |
| mimir.querier.min_cpu                                 | string       | Optional          | Minimum CPU allocated for Querier            |         |
| mimir.querier.min_memory                              | string       | Optional          | Minimum memory allocated for Querier         |         |
| mimir.querier.replicas                                | number       | Optional          | Number of replicas for the Querier           |         |
| mimir.query_frontend.replicas                         | number       | Optional          | Number of replicas for Query Frontend        |         |
| mimir.store_gateway.max_cpu                            | string       | Optional          | Maximum CPU allocated for Store Gateway      |         |
| mimir.store_gateway.max_memory                         | string       | Optional          | Maximum memory allocated for Store Gateway   |         |
| mimir.store_gateway.min_cpu                            | string       | Optional          | Minimum CPU allocated for Store Gateway      |         |
| mimir.store_gateway.min_memory                         | string       | Optional          | Minimum memory allocated for Store Gateway   |         |
| mimir.store_gateway.persistence_volume.size            | string       | Optional          | Size of the persistence volume for Store Gateway |         |
| mimir.store_gateway.replicas                           | number       | Optional          | Number of replicas for Store Gateway         |         |
| mimir.store_gateway.replication_factor                 | number       | Optional          | Replication factor for Store Gateway         |         |





### Tempo

| inputs                                                     | Type         | Required/Optional | <div style="width:400px">Description</div>                 | Default   |
|------------------------------------------------------------|--------------|-------------------|------------------------------------------------------------|-----------|
| tempo.alerts.compactor_replica                     | number | Optional          | Number of replicas for the Compactor component.                                        |         |
| tempo.alerts.distributor_bytes_received            | number | Optional          | Total bytes received by the Distributor component.                                      |         |
| tempo.alerts.distributor_ingester_appends           | number | Optional          | Number of append operations performed by the Distributor component.                      |         |
| tempo.alerts.distributor_ingester_append_failures   | number | Optional          | Number of failed append operations in the Distributor component.                          |         |
| tempo.alerts.distributor_replica                    | number | Optional          | Number of replicas for the Distributor component.                                       |         |
| tempo.alerts.distributor_spans_received             | number | Optional          | Total number of spans received by the Distributor component.                            |         |
| tempo.alerts.ingester_blocks_flushed                | number | Optional          | Number of blocks flushed by the Ingester component.                                      |         |
| tempo.alerts.ingester_bytes_received                | number | Optional          | Total bytes received by the Ingester component.                                          |         |
| tempo.alerts.ingester_live_traces                   | number | Optional          | Number of live traces being processed by the Ingester component.                         |         |
| tempo.alerts.ingester_replica                       | number | Optional          | Number of replicas for the Ingester component.                                          |         |
| tempo.alerts.query_frontend_replica                 | number | Optional          | Number of replicas for the Query Frontend component.                                    |         |
| tempo.alerts.querier_replica                        | number | Optional          | Number of replicas for the Querier component.                                           |         |
| tempo.alerts.tempodb_blocklist                      | number | Optional          | Number of blocks listed in the Tempodb blocklist.                                        |         |
| tempo.distributor.autoscaling                              | boolean      | Optional          | Enable autoscaling for Distributor.                        | `true`    |
| tempo.distributor.cpu_utilization                          | number       | Optional          | CPU utilization threshold for autoscaling.                 | `""`      |
| tempo.distributor.max_cpu                                  | string       | Optional          | Maximum CPU allocated for each Distributor replica.        | `null`    |
| tempo.distributor.max_memory                               | string       | Optional          | Maximum memory allocated for each Distributor replica.     | `null`    |
| tempo.distributor.max_replicas                             | number       | Optional          | Maximum number of Distributor replicas during autoscaling. | `30`      |
| tempo.distributor.memory_utilization                       | number       | Optional          | Memory utilization threshold for autoscaling.              | `""`      |
| tempo.distributor.min_cpu                                  | string       | Optional          | Minimum CPU allocated for each Distributor replica.        | `null`    |
| tempo.distributor.min_memory                               | string       | Optional          | Minimum memory allocated for each Distributor replica.     | `750Mi`   |
| tempo.distributor.min_replicas                             | number       | Optional          | Minimum number of Distributor replicas during autoscaling. | `2`       |
| tempo.distributor.replicas                                 | number       | Optional          | Number of replicas for the Distributor.                    | `1`       |
| tempo.enable                                         | boolean      | Required          | enable tempo for observability setup                       | `false`   |
| tempo.enable_ingress                                               | boolean      | Optional         |   Enable or disable the ingress for tempo components.                      |   |
| tempo.ingester.autoscaling                                 | boolean      | Optional          | Enable autoscaling for Ingester.                           | `true`    |
| tempo.ingester.cpu_utilization                             | number       | Optional          | CPU utilization threshold for autoscaling.                 | `""`      |
| tempo.ingester.max_cpu                                     | string       | Optional          | Maximum CPU allocated for each Ingester replica.           | `null`    |
| tempo.ingester.max_memory                                  | string       | Optional          | Maximum memory allocated for each Ingester replica.        | `null`    |
| tempo.ingester.max_replicas                                | number       | Optional          | Maximum number of Ingester replicas during autoscaling.    | `30`      |
| tempo.ingester.memory_utilization                          | number       | Optional          | Memory utilization threshold for autoscaling.              | `""`      |
| tempo.ingester.min_cpu                                     | string       | Optional          | Minimum CPU allocated for each Ingester replica.           | `null`    |
| tempo.ingester.min_memory                                  | string       | Optional          | Minimum memory allocated for each Ingester replica.        | `1Gi`     |
| tempo.ingester.min_replicas                                | number       | Optional          | Minimum number of Ingester replicas during autoscaling.    | `2`       |
| tempo.ingester.replicas                                    | number       | Optional          | Number of replicas for the Ingester.                       | `1`       |
| tempo.max_receiver_msg_size                                | number       | Optional          | Max gRPC message size that can be received                 | `4700000` |
| tempo.metrics_generator.enable                         | bool         | Optional          | Enable metrics generator for tempo datasource           | `false` |
| tempo.metrics_generator.metrics_ingestion_time_range_slack | string       | Optional          | Metrics ingestion time range slack                      | `40s`   |
| tempo.metrics_generator.remote_write                   | list(object) | Optional          | Prometheus remote write configs for service graph metrics | `null`  |
| tempo.metrics_generator.remote_write.flush_deadline    | string       | Optional          | Remote write storage flush deadline                     | `2m`    |
| tempo.metrics_generator.remote_write.header            | object       | Required          | Header needed for storage remote write                  | `null`  |
| tempo.metrics_generator.remote_write.header.key        | string       | Required          | Header key needed for storage remote write              | `null`  |
| tempo.metrics_generator.remote_write.header.value      | string       | Required          | Header value needed for storage remote write            | `null`  |
| tempo.metrics_generator.remote_write.host              | string       | Required          | host(url) of storage remote write                       | `null`  |
| tempo.metrics_generator.replicas                       | number       | Optional          | Number of replicas for the metrics generator            | `1`     |
| tempo.metrics_generator.service_graphs_max_items       | number       | Optional          | Maximum items in service graphs                         | `30000` |
| tempo.metrics_generator.service_graphs_wait            | string       | Optional          | Wait time for service graphs                            | `30s`   |
| tempo.querier.replicas                                     | number       | Optional          | Number of replicas for the Querier.                        | `1`       |
| tempo.queryfrontend.replicas                               | number       | Optional          | Number of replicas for the Query Frontend.                 | `1`       |