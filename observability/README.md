# Observability Terraform Module

The `observability` module focuses on setting up `Loki for Logs`, `Cortex for Metrics` and `Tempo for Traces` in Kubernetes Cluster using Helm Releases.


### Cortex

- Cortex is a horizontally scalable, highly available, multi-tenant, long term Prometheus. 
- The cortex-helm-chart helps the operator with deploying cortex on a Kubernetes cluster. 

  Helm Chart: https://cortexproject.github.io/cortex-helm-chart/


### Loki

- Loki is a horizontally scalable, highly available, multi-tenant log aggregation system inspired by Prometheus. 
- It is designed to be very cost effective and easy to operate. 
- It does not index the contents of the logs, but rather a set of labels for each log stream.

  Helm Chart: https://grafana.github.io/helm-charts


### Tempo

- Tempo is an open source, easy-to-use, and high-scale distributed tracing backend. 
- Tempo is cost-efficient, requiring only object storage to operate, and is deeply integrated with Grafana, Prometheus, and Loki. 
- Tempo can ingest common open source tracing protocols, including Jaeger, Zipkin, and OpenTelemetry.

  Helm Chart: https://grafana.github.io/helm-charts

#### Variables

| Inputs                    | Type         | Required/Optional | <div style="width:400px">Description</div>                                                                                             | Default |
|---------------------------|--------------|-------------------|-----------------------------------------------------------------------------------------------------------------------------------------|---------|
| app_env                   | string       | Required          | Application deployment environment.                                                                                                    | ""      |
| app_name                  | string       | Required          | This is the name for the project. This name is also used to namespace all the other resources created by this module.                   |         |
| app_region                | string       | Required          | Cloud region to deploy to (e.g. us-east1).                                                                                             |         |
| cortex                    | object       | Required          | Cortex configuration for observability setup.                                                                                          |         |
| domain_name               | string       | Required          | Cloud DNS host name for the service.                                                                                                   | ""      |
| hosted_zone               | string       | Required          | Hosted zone name for the records.                                                                                                      | ""      |
| labels                    | map(string)  | Required          | Common Labels on the resources.                                                                                                        |         |
| loki                      | object       | Required          | Loki configuration for observability setup.                                                                                            |         |
| mimir                     | object       | Required          | Mimir configuration for observability setup.                                                                                            |         |
| observability_suffix      | string       | Required          | To add a suffix to Storage Buckets in Observability Cluster.                                                                            | ""      |
| project_id                | string       | Required          | Project ID.                                                                                                                             | ""      |
| service_account_name_prefix | string    | Required          | Prefix to be used for Service Account Names.                                                                                           |         |
| tempo                     | object       | Required          | Tempo configuration for observability setup.                                                                                           |         |

#### Cortex

| Inputs                                      | Type         | Required/Optional | <div style="width:400px">Description</div> | Default |
|---------------------------------------------|--------------|-------------------|---------------------------------------------|---------|
| alerts                                      | object       | Optional          |                                             |         |
| alerts.compactor_replica                   | number       | Optional          |                                             |         |
| alerts.distributor_replica                 | number       | Optional          |                                             |         |
| alerts.ingester_replica                    | number       | Optional          |                                             |         |
| alerts.query_frontend_replica              | number       | Optional          |                                             |         |
| alerts.querier_replica                     | number       | Optional          |                                             |         |
| compactor                                      | object       | Optional          |                                             |         |
| compactor.enable                           | bool         | Optional          |                                             |         |
| compactor.max_cpu                          | string       | Optional          |                                             |         |
| compactor.max_memory                       | string       | Optional          |                                             |         |
| compactor.min_cpu                          | string       | Optional          |                                             |         |
| compactor.min_memory                       | string       | Optional          |                                             |         |
| compactor.persistence_volume                                      | object       | Optional          |                                             |         |
| compactor.persistence_volume.enable       | bool         | Optional          |                                             |         |
| compactor.persistence_volume.size         | string       | Optional          |                                             |         |
| compactor.replicas                         | number       | Optional          |                                             |         |
| distributor                                      | object       | Optional          |                                             |         |
| distributor.autoscaling                    | bool         | Optional          |                                             |         |
| distributor.cpu_utilization                | string       | Optional          |                                             |         |
| distributor.max_cpu                        | string       | Optional          |                                             |         |
| distributor.max_memory                     | string       | Optional          |                                             |         |
| distributor.max_replicas                   | number       | Optional          |                                             |         |
| distributor.memory_utilization             | string       | Optional          |                                             |         |
| distributor.min_cpu                        | string       | Optional          |                                             |         |
| distributor.min_memory                     | string       | Optional          |                                             |         |
| distributor.min_replicas                   | number       | Optional          |                                             |         |
| distributor.replicas                       | number       | Optional          |                                             |         |
| enable                                     | bool         | Required          |                                             |         |
| enable_ingress                             | bool         | Optional          |                                             |         |
| ingester                                      | object       | Optional          |                                             |         |
| ingester.autoscaling                       | bool         | Optional          |                                             |         |
| ingester.max_cpu                            | string       | Optional          |                                             |         |
| ingester.max_memory                         | string       | Optional          |                                             |         |
| ingester.memory_utilization                 | string       | Optional          |                                             |         |
| ingester.min_cpu                            | string       | Optional          |                                             |         |
| ingester.min_memory                         | string       | Optional          |                                             |         |
| ingester.max_replicas                       | number       | Optional          |                                             |         |
| ingester.min_replicas                       | number       | Optional          |                                             |         |
| ingester.persistence_volume                                      | object       | Optional          |                                             |         |
| ingester.persistence_volume.size            | string       | Optional          |                                             |         |
| ingester.replicas                           | number       | Optional          |                                             |         |
| limits                                      | object       | Optional          |                                             |         |
| limits.ingestion_burst_size                 | number       | Optional          |                                             |         |
| limits.ingestion_rate                      | number       | Optional          |                                             |         |
| limits.max_fetched_chunks_per_query        | number       | Optional          |                                             |         |
| limits.max_series_per_metric               | number       | Optional          |                                             |         |
| limits.max_series_per_user                 | number       | Optional          |                                             |         |
| memcached_blocks                                      | object       | Optional          |                                             |         |
| memcached_blocks.enable                     | bool         | Optional          |                                             |         |
| memcached_blocks.max_cpu                    | string       | Optional          |                                             |         |
| memcached_blocks.max_memory                 | string       | Optional          |                                             |         |
| memcached_blocks.min_cpu                    | string       | Optional          |                                             |         |
| memcached_blocks.min_memory                 | string       | Optional          |                                             |         |
| memcached_blocks_index                                      | object       | Optional          |                                             |         |
| memcached_blocks_index.enable              | bool         | Optional          |                                             |         |
| memcached_blocks_index.max_cpu             | string       | Optional          |                                             |         |
| memcached_blocks_index.max_memory          | string       | Optional          |                                             |         |
| memcached_blocks_index.min_cpu             | string       | Optional          |                                             |         |
| memcached_blocks_index.min_memory          | string       | Optional          |                                             |         |
| memcached_blocks_metadata                                      | object       | Optional          |                                             |         |
| memcached_blocks_metadata.enable           | bool         | Optional          |                                             |         |
| memcached_blocks_metadata.max_cpu          | string       | Optional          |                                             |         |
| memcached_blocks_metadata.max_memory       | string       | Optional          |                                             |         |
| memcached_blocks_metadata.min_cpu          | string       | Optional          |                                             |         |
| memcached_blocks_metadata.min_memory       | string       | Optional          |                                             |         |
| memcached_frontend                                      | object       | Optional          |                                             |         |
| memcached_frontend.enable                  | bool         | Optional          |                                             |         |
| memcached_frontend.max_cpu                 | string       | Optional          |                                             |         |
| memcached_frontend.max_memory              | string       | Optional          |                                             |         |
| memcached_frontend.min_cpu                 | string       | Optional          |                                             |         |
| memcached_frontend.min_memory              | string       | Optional          |                                             |         |
| querier                                      | object       | Optional          |                                             |         |
| querier.autoscaling                        | bool         | Optional          |                                             |         |
| querier.cpu_utilization                    | string       | Optional          |                                             |         |
| querier.max_cpu                            | string       | Optional          |                                             |         |
| querier.max_memory                         | string       | Optional          |                                             |         |
| querier.max_replicas                       | number       | Optional          |                                             |         |
| querier.memory_utilization                 | string       | Optional          |                                             |         |
| querier.min_cpu                            | string       | Optional          |                                             |         |
| querier.min_memory                         | string       | Optional          |                                             |         |
| querier.min_replicas                       | number       | Optional          |                                             |         |
| querier.replicas                           | number       | Optional          |                                             |         |
| query_frontend                                      | object       | Optional          |                                             |         |
| query_frontend.enable                     | bool         | Optional          |                                             |         |
| query_frontend.replicas                   | number       | Optional          |                                             |         |
| query_range                                      | object       | Optional          |                                             |         |
| query_range.memcached_client_timeout      | string       | Optional          |                                             |         |
| store_gateway                                      | object       | Optional          |                                             |         |
| store_gateway.max_cpu                     | string       | Optional          |                                             |         |
| store_gateway.max_memory                  | string       | Optional          |                                             |         |
| store_gateway.min_cpu                     | string       | Optional          |                                             |         |
| store_gateway.min_memory                  | string       | Optional          |                                             |         |
| store_gateway.persistence_volume.size     | string       | Optional          |                                             |         |
| store_gateway.replication_factor          | number       | Optional          |                                             |         |
| store_gateway.replicas                    | number       | Optional          |                                             |         |


#### loki

| Inputs                                      | Type         | Required/Optional | <div style="width:400px">Description</div> | Default |
|---------------------------------------------|--------------|-------------------|---------------------------------------------|---------|
| alerts                                      | object       | Optional          |                                             |         |
| alerts.compactor_replica                    | number       | Optional          |                                             |         |
| alerts.distributor_replica                  | number       | Optional          |                                             |         |
| alerts.ingester_replica                     | number       | Optional          |                                             |         |
| alerts.query_frontend_replica               | number       | Optional          |                                             |         |
| alerts.querier_replica                      | number       | Optional          |                                             |         |
| alerts.distributor_lines_received           | string       | Optional          |                                             |         |
| alerts.distributor_bytes_received           | number       | Optional          |                                             |         |
| alerts.distributor_appended_failures        | number       | Optional          |                                             |         |
| alerts.request_errors                      | number       | Optional          |                                             |         |
| alerts.panics                               | number       | Optional          |                                             |         |
| alerts.request_latency                     | number       | Optional          |                                             |         |
| distributor                                      | object       | Optional          |                                             |         |
| distributor.autoscaling                     | bool         | Optional          |                                             |         |
| distributor.cpu_utilization                 | string       | Optional          |                                             |         |
| distributor.max_cpu                         | string       | Optional          |                                             |         |
| distributor.max_memory                      | string       | Optional          |                                             |         |
| distributor.max_replicas                    | number       | Optional          |                                             |         |
| distributor.memory_utilization              | string       | Optional          |                                             |         |
| distributor.min_cpu                         | string       | Optional          |                                             |         |
| distributor.min_memory                      | string       | Optional          |                                             |         |
| distributor.min_replicas                    | number       | Optional          |                                             |         |
| distributor.replicas                        | number       | Optional          |                                             |         |
| enable                                      | bool         | Required          |                                             |         |
| enable_ingress                              | bool         | Optional          |                                             |         |
| ingester                                      | object       | Optional          |                                             |         |
| ingester.autoscaling                        | bool         | Optional          |                                             |         |
| ingester.max_cpu                             | string       | Optional          |                                             |         |
| ingester.max_memory                          | string       | Optional          |                                             |         |
| ingester.memory_utilization                  | string       | Optional          |                                             |         |
| ingester.min_cpu                             | string       | Optional          |                                             |         |
| ingester.min_memory                          | string       | Optional          |                                             |         |
| ingester.max_replicas                        | number       | Optional          |                                             |         |
| ingester.min_replicas                        | number       | Optional          |                                             |         |
| ingester.persistence_volume                                      | object       | Optional          |                                             |         |
| ingester.persistence_volume.size             | string       | Optional          |                                             |         |
| ingester.replicas                            | number       | Optional          |                                             |         |
| querier                                      | object       | Optional          |                                             |         |
| querier.autoscaling                         | bool         | Optional          |                                             |         |
| querier.cpu_utilization                     | string       | Optional          |                                             |         |
| querier.max_cpu                             | string       | Optional          |                                             |         |
| querier.max_memory                          | string       | Optional          |                                             |         |
| querier.max_replicas                        | number       | Optional          |                                             |         |
| querier.max_unavailable                        | number       | Optional          |                                             |         |
| querier.memory_utilization                  | string       | Optional          |                                             |         |
| querier.min_cpu                             | string       | Optional          |                                             |         |
| querier.min_memory                          | string       | Optional          |                                             |         |
| querier.min_replicas                        | number       | Optional          |                                             |         |
| querier.replicas                            | number       | Optional          |                                             |         |
| query_frontend                                      | object       | Optional          |                                             |         |
| query_frontend.autoscaling                  | bool         | Optional          |                                             |         |
| query_frontend.cpu_utilization              | string       | Optional          |                                             |         |
| query_frontend.max_cpu                      | string       | Optional          |                                             |         |
| query_frontend.max_memory                   | string       | Optional          |                                             |         |
| query_frontend.max_replicas                 | number       | Optional          |                                             |         |
| query_frontend.memory_utilization           | string       | Optional          |                                             |         |
| query_frontend.min_cpu                      | string       | Optional          |                                             |         |
| query_frontend.min_memory                   | string       | Optional          |                                             |         |
| query_frontend.min_replicas                 | number       | Optional          |                                             |         |
| query_frontend.replicas                    | number       | Optional          |                                             |         |


#### mimir

| Inputs                                      | Type         | Required/Optional | <div style="width:400px">Description</div> | Default |
|---------------------------------------------|--------------|-------------------|---------------------------------------------|---------|
| alerts                                      | object       | Optional          |                                             |         |
| alerts.compactor_replica                    | number       | Optional          |                                             |         |
| alerts.distributor_replica                  | number       | Optional          |                                             |         |
| alerts.ingester_replica                     | number       | Optional          |                                             |         |
| alerts.query_frontend_replica               | number       | Optional          |                                             |         |
| alerts.querier_replica                      | number       | Optional          |                                             |         |
| compactor                                   | object       | Optional          |                                             |         |
| compactor.max_cpu                           | string       | Optional          |                                             |         |
| compactor.max_memory                        | string       | Optional          |                                             |         |
| compactor.min_cpu                           | string       | Optional          |                                             |         |
| compactor.min_memory                        | string       | Optional          |                                             |         |
| compactor.persistence_volume                | object       | Optional          |                                             |         |
| compactor.persistence_volume.enable        | bool         | Optional          |                                             |         |
| compactor.persistence_volume.size          | string       | Optional          |                                             |         |
| compactor.replicas                          | number       | Optional          |                                             |         |
| distributor                                 | object       | Optional          |                                             |         |
| distributor.max_cpu                         | string       | Optional          |                                             |         |
| distributor.max_memory                      | string       | Optional          |                                             |         |
| distributor.min_cpu                         | string       | Optional          |                                             |         |
| distributor.min_memory                      | string       | Optional          |                                             |         |
| distributor.replicas                        | number       | Optional          |                                             |         |
| enable                                      | bool         | Required          |                                             |         |
| enable_ingress                              | bool         | Optional          |                                             |         |
| ingester                                    | object       | Optional          |                                             |         |
| ingester.max_cpu                            | string       | Optional          |                                             |         |
| ingester.max_memory                         | string       | Optional          |                                             |         |
| ingester.min_cpu                            | string       | Optional          |                                             |         |
| ingester.min_memory                         | string       | Optional          |                                             |         |
| ingester.persistence_volume                 | object       | Optional          |                                             |         |
| ingester.persistence_volume.size            | string       | Optional          |                                             |         |
| ingester.replicas                           | number       | Optional          |                                             |         |
| limits                                      | object       | Optional          |                                             |         |
| limits.ingestion_burst_size                 | number       | Optional          |                                             |         |
| limits.ingestion_rate                       | number       | Optional          |                                             |         |
| limits.max_cache_freshness                  | number       | Optional          |                                             |         |
| limits.max_fetched_chunks_per_query         | number       | Optional          |                                             |         |
| limits.max_outstanding_requests_per_tenant  | number       | Optional          |                                             |         |
| querier                                     | object       | Optional          |                                             |         |
| querier.max_cpu                             | string       | Optional          |                                             |         |
| querier.max_memory                          | string       | Optional          |                                             |         |
| querier.min_cpu                             | string       | Optional          |                                             |         |
| querier.min_memory                          | string       | Optional          |                                             |         |
| querier.replicas                            | number       | Optional          |                                             |         |
| query_frontend                              | object       | Optional          |                                             |         |
| query_frontend.replicas                     | number       | Optional          |                                             |         |
| store_gateway                               | object       | Optional          |                                             |         |
| store_gateway.max_cpu                       | string       | Optional          |                                             |         |
| store_gateway.max_memory                    | string       | Optional          |                                             |         |
| store_gateway.min_cpu                       | string       | Optional          |                                             |         |
| store_gateway.min_memory                    | string       | Optional          |                                             |         |
| store_gateway.persistence_volume            | object       | Optional          |                                             |         |
| store_gateway.persistence_volume.size       | string       | Optional          |                                             |         |
| store_gateway.replication_factor            | number       | Optional          |                                             |         |
| store_gateway.replicas                      | number       | Optional          |                                             |         |


#### tempo

| Inputs                                      | Type         | Required/Optional | <div style="width:400px">Description</div> | Default |
|---------------------------------------------|--------------|-------------------|---------------------------------------------|---------|
| alerts                                      | object       | Optional          |                                             |         |
| alerts.compactor_replica                    | number       | Optional          |                                             |         |
| alerts.distributor_bytes_received           | number       | Optional          |                                             |         |
| alerts.distributor_ingester_append_failures | number       | Optional          |                                             |         |
| alerts.distributor_ingester_appends         | number       | Optional          |                                             |         |
| alerts.distributor_replica                  | number       | Optional          |                                             |         |
| alerts.distributor_spans_received           | number       | Optional          |                                             |         |
| alerts.ingenser_bytes_received              | number       | Optional          |                                             |         |
| alerts.ingenser_blocks_flushed              | number       | Optional          |                                             |         |
| alerts.ingenser_live_traces                 | number       | Optional          |                                             |         |
| alerts.query_frontend_replica               | number       | Optional          |                                             |         |
| alerts.querier_replica                      | number       | Optional          |                                             |         |
| alerts.tempodb_blocklist                    | number       | Optional          |                                             |         |
| distributor                                 | object       | Optional          |                                             |         |
| distributor.autoscaling                     | bool         | Optional          |                                             |         |
| distributor.cpu_utilization                 | string       | Optional          |                                             |         |
| distributor.max_cpu                         | string       | Optional          |                                             |         |
| distributor.max_memory                      | string       | Optional          |                                             |         |
| distributor.max_replicas                    | number       | Optional          |                                             |         |
| distributor.memory_utilization              | string       | Optional          |                                             |         |
| distributor.min_cpu                         | string       | Optional          |                                             |         |
| distributor.min_memory                      | string       | Optional          |                                             |         |
| distributor.min_replicas                    | number       | Optional          |                                             |         |
| distributor.replicas                        | number       | Optional          |                                             |         |
| enable                                      | bool         | Required          |                                             |         |
| enable_ingress                              | bool         | Optional          |                                             |         |
| ingester                                    | object       | Optional          |                                             |         |
| ingester.autoscaling                        | bool         | Optional          |                                             |         |
| ingester.cpu_utilization                    | string       | Optional          |                                             |         |
| ingester.max_cpu                             | string       | Optional          |                                             |         |
| ingester.max_memory                          | string       | Optional          |                                             |         |
| ingester.max_replicas                        | number       | Optional          |                                             |         |
| ingester.memory_utilization                  | string       | Optional          |                                             |         |
| ingester.min_cpu                             | string       | Optional          |                                             |         |
| ingester.min_memory                          | string       | Optional          |                                             |         |
| ingester.min_replicas                        | number       | Optional          |                                             |         |
| ingester.replicas                            | number       | Optional          |                                             |         |
| max_receiver_msg_size                       | number       | Optional          |                                             |         |
| metrics_generator                           | object       | Optional          |                                             |         |
| metrics_generator.enable                    | bool         | Optional          |                                             |         |
| metrics_generator.metrics_ingestion_time_range_slack | string  | Optional          |                                             |         |
| metrics_generator.remote_write              | list(object) | Optional          |                                             |         |
| metrics_generator.remote_write.header       | object       | Optional          |                                             |         |
| metrics_generator.remote_write.header.key   | string       | Optional          |                                             |         |
| metrics_generator.remote_write.header.value | string       | Optional          |                                             |         |
| metrics_generator.remote_write.host         | string       | Optional          |                                             |         |
| metrics_generator.remote_write_flush_deadline | string   | Optional          |                                             |         |
| metrics_generator.replicas                  | number       | Optional          |                                             |         |
| metrics_generator.service_graphs_max_items  | number       | Optional          |                                             |         |
| metrics_generator.service_graphs_wait       | string       | Optional          |                                             |         |
| querier                                     | object       | Optional          |                                             |         |
| querier.replicas                            | number       | Optional          |                                             |         |
| query_frontend                              | object       | Optional          |                                             |         |
| query_frontend.replicas                     | number       | Optional          |                                             |         |
