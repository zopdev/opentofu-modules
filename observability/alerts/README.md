# Observability

#### Variables

| Inputs           | Type         | Required/Optional | <div style="width:400px">Description</div>                                                        | Default |
|------------------|--------------|-------------------|-----------------------------------------------------------------------------------------------------|---------|
| cluster_name     | string       | Required          | Name of cluster where alerts are being configured                                                  | `""`    |
| cortex           | object       | Required          | Cortex alerts configuration                                                                       | `null`  |
| loki             | object       | Required          | Loki alerts configuration                                                                         | `null`  |
| mimir            | object       | Required          | Mimir alerts configuration                                                                        | `null`  |
| tempo            | object       | Required          | Tempo alerts configuration                                                                        | `null`  |

### Cortex

| Inputs                                          | Type         | Required/Optional | <div style="width:450px">Description</div>                                           | Default |
|-------------------------------------------------|--------------|-------------------|----------------------------------------------------------------------------------------|---------|
| cortex.alerts.compactor_replica                 | number       | Optional          | Number of Compactor replicas to monitor.                                             |         |
| cortex.alerts.distributor_replica                | number       | Optional          | Number of Distributor replicas to monitor.                                            |         |
| cortex.alerts.ingester_replica                   | number       | Optional          | Number of Ingester replicas to monitor.                                              |         |
| cortex.alerts.query_frontend_replica             | number       | Optional          | Number of Query Frontend replicas to monitor.                                        |         |
| cortex.alerts.querier_replica                    | number       | Optional          | Number of Querier replicas to monitor.                                                |         |
| cortex.enable                                   | boolean      | Required          | Enable Cortex for observability setup.                                                |  |
| cortex.enable_ingress                           | boolean      | Optional          | Enable ingress for Cortex.                                                              |  |

### Loki

| Inputs                                          | Type         | Required/Optional | <div style="width:450px">Description</div>                                           | Default |
|-------------------------------------------------|--------------|-------------------|----------------------------------------------------------------------------------------|---------|
| loki.alerts.compactor_replica                  | number       | Optional          | Number of Compactor replicas to monitor.                                             |         |
| loki.alerts.distributor_appended_failures       | number       | Optional          | Number of Distributor appended failures to monitor.                                   |         |
| loki.alerts.distributor_bytes_received          | number       | Optional          | Bytes received by the Distributor to monitor.                                         |         |
| loki.alerts.distributor_lines_received          | string       | Optional          | Lines received by the Distributor to monitor.                                         |         |
| loki.alerts.distributor_replica                 | number       | Optional          | Number of Distributor replicas to monitor.                                            |         |
| loki.alerts.ingester_replica                    | number       | Optional          | Number of Ingester replicas to monitor.                                              |         |
| loki.alerts.panics                              | number       | Optional          | Number of system panics to monitor.                                                   |         |
| loki.alerts.query_frontend_replica              | number       | Optional          | Number of Query Frontend replicas to monitor.                                        |         |
| loki.alerts.querier_replica                     | number       | Optional          | Number of Querier replicas to monitor.                                                |         |
| loki.alerts.request_errors                      | number       | Optional          | Number of request errors to monitor.                                                   |         |
| loki.alerts.request_latency                     | number       | Optional          | Request latency to monitor.                                                             |         |
| loki.enable                                   | boolean      | Required          | Enable Loki for observability setup.                                                   |  |

### Mimir

| Inputs                                          | Type         | Required/Optional | <div style="width:450px">Description</div>                                           | Default |
|-------------------------------------------------|--------------|-------------------|----------------------------------------------------------------------------------------|---------|
| mimir.alerts.compactor_replica                 | number       | Optional          | Number of Compactor replicas to monitor.                                             |         |
| mimir.alerts.distributor_replica                | number       | Optional          | Number of Distributor replicas to monitor.                                            |         |
| mimir.alerts.ingester_replica                   | number       | Optional          | Number of Ingester replicas to monitor.                                              |         |
| mimir.alerts.query_frontend_replica             | number       | Optional          | Number of Query Frontend replicas to monitor.                                        |         |
| mimir.alerts.querier_replica                    | number       | Optional          | Number of Querier replicas to monitor.                                                |         |
| mimir.enable                                   | boolean      | Required          | Enable Mimir for observability setup.                                                 |  |
| mimir.enable_ingress                           | boolean      | Optional          | Enable ingress for Mimir observability setup.                                         |         |

### Tempo

| Inputs                                      | Type         | Required/Optional | <div style="width:450px">Description</div>                                           | Default |
|---------------------------------------------|--------------|-------------------|----------------------------------------------------------------------------------------|---------|
| tempo.alerts.compactor_replica              | number       | Optional          | Number of Compactor replicas to monitor.                                             |         |
| tempo.alerts.distributor_bytes_received      | number       | Optional          | Bytes received by the Distributor to monitor.                                        |         |
| tempo.alerts.distributor_ingester_append_failures | number | Optional          | Failures in Distributor Ingester appends to monitor.                                  |         |
| tempo.alerts.distributor_ingester_appends    | number       | Optional          | Number of Ingester appends by the Distributor to monitor.                             |         |
| tempo.alerts.distributor_replica            | number       | Optional          | Number of Distributor replicas to monitor.                                            |         |
| tempo.alerts.distributor_spans_received      | number       | Optional          | Spans received by the Distributor to monitor.                                         |         |
| tempo.alerts.ingester_bytes_received         | number       | Optional          | Bytes received by the Ingester to monitor.                                            |         |
| tempo.alerts.ingester_blocks_flushed        | number       | Optional          | Number of blocks flushed by the Ingester to monitor.                                  |         |
| tempo.alerts.ingester_live_traces            | number       | Optional          | Live traces handled by the Ingester to monitor.                                       |         |
| tempo.alerts.ingester_replica                | number       | Optional          | Number of Ingester replicas to monitor.                                               |         |
| tempo.alerts.query_frontend_replica          | number       | Optional          | Number of Query Frontend replicas to monitor.                                         |         |
| tempo.alerts.querier_replica                 | number       | Optional          | Number of Querier replicas to monitor.                                                |         |
| tempo.alerts.tempodb_blocklist               | number       | Optional          | Number of blocks in the Tempodb blocklist to monitor.                                 |         |
| tempo.enable                               | boolean      | Required          | Enable Tempo for observability setup.                                                 |  |
