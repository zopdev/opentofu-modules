# GCP GKE Terraform module

The `gke` module contains all resources that are required for creating a GCP GKE cluster, node pools, domain configuration,
prometheus/grafana setup etc. This module is the root module of all the other modules such as `db`, `redis`, `observability` etc.

## Values

| Inputs                    | Type         | Required/Optional | <div style="width:400px">Description</div>                                                                               | Default                                     |
|---------------------------|--------------|-------------------|--------------------------------------------------------------------------------------------------------------------------|---------------------------------------------|
| accessibility                    | object             | Optional          | The list of user access for the account setup.                                                                                         | `null`  |
| app_env                   | string       | Required          | Application deployment environment                                                                                       | `null`                                      | 
| app_name                  | string       | Required          | Name of the cluster                                                                                                      | `null`                                      | 
| app_namespaces            | map(object)  | Optional          | Details for setting up different types of alerts at namespace level                                                      | `{}`                                        | 
| app_region                | string       | Required          | Cloud region to deploy resources                                                                                         | `null`                                      | 
| appd_accesskey            | string       | Optional          | AppDynamics Accesskey                                                                                                    | `""`                                        | 
| appd_account              | string       | Optional          | AppDynamics Account                                                                                                      | `""`                                        | 
| appd_controller_url       | string       | Optional          | AppDynamics Controller URL                                                                                               | `""`                                        |
| appd_password             | string       | Optional          | AppDynamics Password                                                                                                     | `""`                                        | 
| appd_user                 | string       | Optional          | AppDynamics Username                                                                                                     | `""`                                        | 
| cluster_alert_thresholds  | object       | Optional          | Cluster alerts threshold configuration                                                                                   | For default values, [click here](./vars.tf) |
| cluster_alert_webhooks    | list(object) | Optional          | Details for setting up of different types of alerts at cluster level, for example configuration, [click here](./vars.tf) | `[]`                                        | 
| cluster_config            | map(any)     | Optional          | Any additional configurations to be implemented in the cluster                                                           | `{}`                                        |
| common_tags               | map(string)  | Optional          | Additional tags for merging with common tags for resources                                                     | `{}`                                        | 
| custom_inbound_ip_range          | list(string)       | Optional          | List of custom IP ranges that are allowed to access services on the GKE cluster.                                                      | `[]`    |
| fluent_bit                       | object             | Optional          | Inputs for Fluent Bit configurations.                                                                                                  | `null`  |
| moogsoft_endpoint_api_key | string       | Optional          | Moogsoft API key to configure your third-party system to send data to Moogsoft                                           | `""`                                        | 
| moogsoft_username         | string       | Optional          | Username for moogsoft authentication                                                                                     | `""`                                        |
| namespace_folder_list     | list(string) | Required          | List of Namespaces configured in the cluster                                                                             | `[]`                                        | 
| node_config                      | object             | Required          | List of values for the node configuration of Kubernetes cluster.                                                                        |         |
| observability_config             | object             | Optional          | All the configuration related to observability (e.g., Prometheus, Grafana, Loki, Tempo, and Cortex).                                   | `null`  |
| pagerduty_integration_key | string       | Optional          | Pagerduty Integration key to send data to Pagerduty                                                                      | `""`                                        | 
| pagerduty_url             | string       | Optional          | Pagerduty URL to configure your third-party system to send data to Pagerduty                                             | `""`                                        |
| provisioner                      | string             | Optional          | Provisioner being used to setup Infra.                                                                                                 | `zop-dev` |
| provider_id               | string       | Required          | ID of the GCP project                                                                                                    | `null`                                      |
| shared_service_provider          | string             | Optional          | Shared Service Provider ID.                                                                                                            | `null`  |
| standard_tags                    | object             | Optional          | Standard tags for resources.                                                                                                           | `null`  |
| subnet                           | string             | Optional          | Subnets IDs the apps are going to use.                                                                                                  | `""`    |
| user_access                      | object             | Optional          | List of users who will have access to clusters.                                                                                         | `{}`    |
| vpc                              | string             | Optional          | VPC the apps are going to use.                                                                                                           | `""`    |
| cert_issuer_env                  | string             | Optional          | Environment (prod or stage) to be used for LetsEncrypt Certificate Issuer.                                                            | `stage` |


### accessibility
| Inputs                    | Type         | Required/Optional | <div style="width:400px">Description</div>             | Default |
|---------------------------|--------------|-------------------|--------------------------------------------------------|---------|
| accessibility.domain_name | string       | Optional          | Cloud DNS host name for the service                    | `null`  |
| accessibility.hosted_zone | string       | Optional          | Hosted zone name for the records                       | `null`  |
| accessibility.cidr_blocks | list(string) | Optional          | Required IP ranges that cluster can be accessible from | `null`  |

### App Namespaces

| Key                     | Type              | Description                                                                               | Default |
|-------------------------|-------------------|-------------------------------------------------------------------------------------------|---------|
| alert_webhooks          | list(object)      | List of alert webhooks for the namespace. Each webhook has the following properties:      | `{}`    |
| alert_webhooks.type  | string            | Type of the alert webhook.                                        |         |
| alert_webhooks.data  | string            | URL or endpoint for the webhook.                                                            |         |
| alert_webhooks.labels| map(string)       | Optional labels to be included with the alert.       

### user_access
| Inputs                  | Type         | Required/Optional | <div style="width:400px">Description</div>           | Default |
|-------------------------|--------------|-------------------|------------------------------------------------------|---------|
| user_access.app_admins  | list(string) | Optional          | List of users who will have admin access to cluster  | `[]`    | 
| user_access.app_editors | list(string) | Optional          | List of users who will have editor access to cluster | `[]`    | 
| user_access.app_viewers | list(string) | Optional          | List of users who will have viewer access to cluster | `[]`    | 

### node_config
| Inputs                             | Type   | Required/Optional | <div style="width:400px">Description</div>         | Default          |
|------------------------------------|--------|-------------------|----------------------------------------------------|------------------|
| node_config.node_type   | string            | Required           | Type of the node (e.g., standard, burstable).                        |         |
| node_config.min_count   | number            | Required           | Minimum number of nodes.                                             |         |
| node_config.max_count   | number            | Required           | Maximum number of nodes.                                             |         |
| node_config.availability_zones | list(string) | Optional           | Optional list of availability zones for the nodes.                  | `[]`    |

### cluster_alert_thresholds
| Inputs                                | Type    | Required/Optional | Description                                 | Default |
|---------------------------------------|---------|-------------------|---------------------------------------------|---------|
| cpu_utilisation                       | number  | Optional          | CPU utilization threshold                   | `80`    |
| cpu_underutilisation                  | number  | Optional          | CPU underutilization threshold              | `20`    |
| node_count                            | number  | Optional          | Node count threshold                        | `80`    |
| memory_utilisation                    | number  | Optional          | Memory utilization threshold                | `80`    |
| memory_underutilisation               | number  | Optional          | Memory underutilization threshold           | `20`    |
| pod_count                             | number  | Optional          | Pod count threshold                         | `80`    |
| nginx_5xx_percentage_threshold        | number  | Optional          | Nginx 5xx percentage threshold              | `5`     |
| disk_utilization                      | number  | Optional          | Disk utilization threshold                  | `20`    |
| cortex_disk_utilization_threshold     | number  | Optional          | Cortex disk utilization threshold           | `80`    |


### observability_config
| inputs                       | Type         | Required/Optional | <div style="width:400px">Description</div>                         | Default                  |
|------------------------------|--------------|-------------------|--------------------------------------------------------------------|--------------------------|
| observability_config.suffix  | string       | Optional          | To add a suffix to Storage Buckets in Observability Cluster        | `""`                     |

#### Prometheus
| inputs                                                         | Type         | Required/Optional | <div style="width:400px">Description</div>    | Default  |
|----------------------------------------------------------------|--------------|-------------------|-----------------------------------------------|----------|
| observability_config.prometheus.enabled                        | boolean      | Optional          | install prometheus helm chart or not          | `true`   | 
| observability_config.prometheus.persistence.disk_size          | string       | Optional          | disk size for prometheus                      | `50Gi`   |
| observability_config.prometheus.persistence.retention_duration | string       | Optional          | disk retention duration                       | `10d`    | 
| observability_config.prometheus.persistence.retention_size     | string       | Optional          | disk retention size                           | `45Gi`   |
| observability_config.prometheus.remote_write                   | list(object) | Optional          | remote_write config                           | `[]`     |
| observability_config.prometheus.remote_write.header            | object       | Required          | headers needed for remote service             | `null`   |
| observability_config.prometheus.remote_write.header.key        | string       | Required          | Header key needed for prometheus remote write | `null`   |
| observability_config.prometheus.remote_write.header.value      | string       | Required          | Header value needed for remote write          | `null`   |
| observability_config.prometheus.remote_write.host              | string       | Required          | host(url) of prometheus remote service        | `null`   |
| observability_config.prometheus.version                        | string       | Optional          | version for kube-prometheus-stack helm chart  | `44.0.0` |

#### grafana
| inputs                                                       | Type         | Required/Optional | <div style="width:400px">Description</div> | Default   |
|--------------------------------------------------------------|--------------|-------------------|--------------------------------------------|-----------|
| observability_config.grafana.dashboard.limit_cpu             | string       | Optional          | CPU limit for Grafana dashboards           | `"512m"`  |
| observability_config.grafana.dashboard.limit_memory          | string       | Optional          | Memory limit for Grafana dashboards        | `"512Mi"` |
| observability_config.grafana.dashboard.request_cpu           | string       | Optional          | Requested CPU for Grafana dashboards       | `"256m"`  |
| observability_config.grafana.dashboard.request_memory        | string       | Optional          | Requested memory for Grafana dashboards    | `"256Mi"` |
| observability_config.grafana.datasource.limit_cpu            | string       | Optional          | CPU limit for Grafana datasources          | `"512m"`  |
| observability_config.grafana.datasource.limit_memory         | string       | Optional          | Memory limit for Grafana datasources       | `"512Mi"` |
| observability_config.grafana.datasource.request_cpu          | string       | Optional          | Requested CPU for Grafana datasources      | `"256m"`  |
| observability_config.grafana.datasource.request_memory       | string       | Optional          | Requested memory for Grafana datasources   | `"256Mi"` |
| observability_config.grafana.enabled                         | boolean      | Optional          | install grafana helm chart                 | `false`   |
| observability_config.grafana.gcloud_monitoring               | boolean      | Optional          | Create gcloud monitoring datasource        | `false`   |
| observability_config.grafana.grafana_configs.datasource_list | list(string) | Optional          | grafana datasource list                    | `[]`      |
| observability_config.grafana.grafana_configs.domains         | list(string) | Optional          | grafana allowed domains                    | `[]`      |
| observability_config.grafana.grafana_configs.enable_sso      | boolean      | Optional          | enable sso or not                          | `false`   |
| observability_config.grafana.max_replica                     | number       | Optional          | Maximum number of Grafana replicas         | `10`      |
| observability_config.grafana.min_replica                     | number       | Optional          | Minimum number of Grafana replicas         | `1`       |
| observability_config.grafana.persistence.disk_size           | string       | Optional          | Disk size for Grafana persistence          | `"10Gi"`  |
| observability_config.grafana.persistence.type                | string       | Optional          | pvc for database as persistence            | `db`      |
| observability_config.grafana.request_cpu                     | string       | Optional          | Requested CPU for Grafana                  | `"100m"`  |
| observability_config.grafana.request_memory                  | string       | Optional          | Requested memory for Grafana               | `"100Mi"` |
| observability_config.grafana.url                             | string       | Optional          | grafana host                               | `""`      |
| observability_config.grafana.version                         | string       | Optional          | grafana-helm helm chart version            | `7.0.8`   |

#### kubernetes_event_exporter

| inputs                                                                     | Type         | Required/Optional | <div style="width:400px">Description</div>                          | Default   |
|----------------------------------------------------------------------------|--------------|-------------------|---------------------------------------------------------------------|-----------|
| observability_config.kubernetes_event_exporter.enabled                     | boolean      | Optional          | Install kubernetes event log exporter helm chart or not             | `false`   | 
| observability_config.kubernetes_event_exporter.log_level                   | string       | Optional          | Log level for the logs                                              | `debug`   |
| observability_config.kubernetes_event_exporter.max_event_age_second        | string       | Optional          | Max event age seconds                                               | `150`     | 
| observability_config.kubernetes_event_exporter.receivers                   | list(object) | Optional          | List of receivers for event logs                                    | `[]`      |
| observability_config.kubernetes_event_exporter.receivers.name              | string       | Optional          | Name of receiver                                                    | `null`    |
| observability_config.kubernetes_event_exporter.receivers.loki              | object       | Optional          | Loki configs as a receiver                                          | `{}`      |
| observability_config.kubernetes_event_exporter.receivers.loki.url          | string       | Optional          | Loki host for sending event logs                                    | `null`    |
| observability_config.kubernetes_event_exporter.receivers.loki.header       | object       | Optional          | Header configs for loki receiver                                    | `{}`      |
| observability_config.kubernetes_event_exporter.receivers.loki.header.key   | string       | Optional          | Header key needed for loki receiver                                 | `null`    |
| observability_config.kubernetes_event_exporter.receivers.loki.header.value | string       | Optional          | Header value needed for loki receiver                               | `null`    |
| observability_config.kubernetes_event_exporter.resource.limit_cpu          | string       | Optional          | Maximum CPU allocated for each kubernetes event exporter replica    | `"400m"`  |
| observability_config.kubernetes_event_exporter.resource.limit_memory       | string       | Optional          | Maximum Memory allocated for each kubernetes event exporter replica | `"250Mi"` |
| observability_config.kubernetes_event_exporter.resource.request_cpu        | string       | Optional          | Maximum CPU allocated for each kubernetes event exporter replica    | `"100m"`  |
| observability_config.kubernetes_event_exporter.resource.request_memory     | string       | Optional          | Maximum Memory allocated for each kubernetes event exporter replica | `"100Mi"` |


#### Loki
| inputs                                                     | Type    | Required/Optional | <div style="width:400px">Description</div>                   | Default |
|------------------------------------------------------------|---------|-------------------|--------------------------------------------------------------|---------|
| observability_config.loki.distributor.autoscaling          | boolean | Optional          | Enable autoscaling for Distributor.                          | `true`  |
| observability_config.loki.distributor.cpu_utilization      | number  | Optional          | CPU utilization threshold for autoscaling.                   | `""`    |
| observability_config.loki.distributor.max_cpu              | string  | Optional          | Maximum CPU allocated for each Distributor replica.          | `1`     |
| observability_config.loki.distributor.max_memory           | string  | Optional          | Maximum memory allocated for each Distributor replica.       | `1Gi`   |
| observability_config.loki.distributor.max_replicas         | number  | Optional          | Maximum number of Distributor replicas during autoscaling.   | `30`    |
| observability_config.loki.distributor.memory_utilization   | number  | Optional          | Memory utilization threshold for autoscaling.                | `""`    |
| observability_config.loki.distributor.min_cpu              | string  | Optional          | Minimum CPU allocated for each Distributor replica.          | `250m`  |
| observability_config.loki.distributor.min_memory           | string  | Optional          | Minimum memory allocated for each Distributor replica.       | `512Mi` |
| observability_config.loki.distributor.min_replicas         | number  | Optional          | Minimum number of Distributor replicas during autoscaling.   | `2`     |
| observability_config.loki.distributor.replicas             | number  | Optional          | Number of replicas for the Distributor.                      | `1`     |
| observability_config.loki.enable                           | boolean | Required          | enable loki for observability setup                          | `false` |
| observability_config.loki.ingester.autoscaling             | boolean | Optional          | Enable autoscaling for Ingester.                             | `true`  |
| observability_config.loki.ingester.cpu_utilization         | number  | Optional          | CPU utilization threshold for autoscaling.                   | `""`    |
| observability_config.loki.ingester.max_cpu                 | string  | Optional          | Maximum CPU allocated for each Ingester replica.             | `null`  |
| observability_config.loki.ingester.max_memory              | string  | Optional          | Maximum memory allocated for each Ingester replica.          | `2Gi`   |
| observability_config.loki.ingester.max_replicas            | number  | Optional          | Maximum number of Ingester replicas during autoscaling.      | `30`    |
| observability_config.loki.ingester.memory_utilization      | number  | Optional          | Memory utilization threshold for autoscaling.                | `""`    |
| observability_config.loki.ingester.min_cpu                 | string  | Optional          | Minimum CPU allocated for each Ingester replica.             | `null`  |
| observability_config.loki.ingester.min_memory              | string  | Optional          | Minimum memory allocated for each Ingester replica.          | `1Gi`   |
| observability_config.loki.ingester.min_replicas            | number  | Optional          | Minimum number of Ingester replicas during autoscaling.      | `2`     |
| observability_config.loki.ingester.replicas                | number  | Optional          | Number of replicas for the Ingester.                         | `1`     |
| observability_config.loki.querier.autoscaling              | boolean | Optional          | Enable autoscaling for Querier.                              | `true`  |
| observability_config.loki.querier.cpu_utilization          | number  | Optional          | CPU utilization threshold for autoscaling.                   | `""`    |
| observability_config.loki.querier.max_cpu                  | string  | Optional          | Maxmum CPU allocated for each Querier replica.               | `null`  |
| observability_config.loki.querier.max_memory               | string  | Optional          | Maxmum memory allocated for each Querier replica.            | `null`  |
| observability_config.loki.querier.max_replicas             | number  | Optional          | Maximum number of Querier replicas during autoscaling.       | `6`     |
| observability_config.loki.querier.memory_utilization       | number  | Optional          | Memory utilization threshold for autoscaling.                | `""`    |
| observability_config.loki.querier.min_cpu                  | string  | Optional          | Minimum CPU allocated for each Querier replica.              | `100m`  |
| observability_config.loki.querier.min_memory               | string  | Optional          | Minimum memory allocated for each Querier replica.           | `500Mi` |
| observability_config.loki.querier.min_replicas             | number  | Optional          | Minimum number of Querier replicas during autoscaling.       | `2`     |
| observability_config.loki.querier.replicas                 | number  | Optional          | Number of replicas for the Querier.                          | `4`     |
| observability_config.loki.querier.max_unavailable          | number  | Optional          | Maximum unavailable replicas for the Querier.                | `1`     |
| observability_config.loki.queryfrontend.autoscaling        | boolean | Optional          | Enable autoscaling for QueryFrontend.                        | `true`  |
| observability_config.loki.queryfrontend.cpu_utilization    | number  | Optional          | CPU utilization threshold for autoscaling.                   | `""`    |
| observability_config.loki.queryfrontend.max_cpu            | string  | Optional          | Maximum CPU allocated for each queryfrontend replica.        | `null`  |
| observability_config.loki.queryfrontend.max_memory         | string  | Optional          | Maximummemory allocated for each queryfrontend replica.      | `null`  |
| observability_config.loki.queryfrontend.max_replicas       | number  | Optional          | Maximum number of QueryFrontend replicas during autoscaling. | `6`     |
| observability_config.loki.queryfrontend.memory_utilization | number  | Optional          | Memory utilization threshold for autoscaling.                | `""`    |
| observability_config.loki.queryfrontend.min_cpu            | string  | Optional          | Minimum CPU allocated for each queryfrontend replica.        | `null`  |
| observability_config.loki.queryfrontend.min_memory         | string  | Optional          | Minimum memory allocated for each queryfrontend replica.     | `250Mi` |
| observability_config.loki.queryfrontend.min_replicas       | number  | Optional          | Minimum number of QueryFrontend replicas during autoscaling. | `1`     |
| observability_config.loki.queryfrontend.replicas           | number  | Optional          | Number of replicas for the QueryFrontend.                    | `1`     |

#### Cortex

| <div style="width:100px">inputs</div>                            | Type    | Required/Optional | <div style="width:100px">Description</div>                           | Default   |
|:-----------------------------------------------------------------|:--------|:------------------|----------------------------------------------------------------------|:----------|
| observability_config.cortex.compactor.enable                     | boolean | Optional          | Enable the Compactor component.                                      | `true`    |
| observability_config.cortex.compactor.max_cpu                    | string  | Optional          | Maximum CPU allocated for each Compactor replica.                    | `null`    |
| observability_config.cortex.compactor.max_memory                 | string  | Optional          | Maximum memory allocated for each Compactor replica.                 | `null`    |
| observability_config.cortex.compactor.min_cpu                    | string  | Optional          | Minimum CPU allocated for each Compactor replica.                    | `null`    |
| observability_config.cortex.compactor.min_memory                 | string  | Optional          | Minimum memory allocated for each Compactor replica.                 | `null`    |
| observability_config.cortex.compactor.persistence_volume.enable  | boolean | Optional          | Enable persistence volume for the Compactor.                         | `true`    |
| observability_config.cortex.compactor.persistence_volume.size    | string  | Optional          | Size of the persistence volume for the Compactor.                    | `"20Gi"`  |
| observability_config.cortex.compactor.replicas                   | number  | Optional          | Number of replicas for the Compactor.                                | `1`       |
| observability_config.cortex.distributor.autoscaling              | boolean | Optional          | Enable autoscaling for Distributor.                                  | `true`    |
| observability_config.cortex.distributor.cpu_utilization          | number  | Optional          | CPU utilization threshold for autoscaling.                           | `""`      |
| observability_config.cortex.distributor.max_cpu                  | string  | Optional          | Maximum CPU allocated for each Distributor replica.                  | `null`    |
| observability_config.cortex.distributor.max_memory               | string  | Optional          | Maximum memory allocated for each Distributor replica.               | `null`    |
| observability_config.cortex.distributor.max_replicas             | number  | Optional          | Maximum number of replicas for the Distributor.                      | `30`      |
| observability_config.cortex.distributor.memory_utilization       | number  | Optional          | Memory utilization threshold for autoscaling.                        | `""`      |
| observability_config.cortex.distributor.min_cpu                  | string  | Optional          | Minimum CPU allocated for each Distributor replica.                  | `null`    |
| observability_config.cortex.distributor.min_memory               | string  | Optional          | Minimum memory allocated for each Distributor replica.               | `null`    |
| observability_config.cortex.distributor.min_replicas             | number  | Optional          | Minimum number of replicas for the Distributor.                      | `2`       |
| observability_config.cortex.distributor.replicas                 | number  | Optional          | Number of replicas for the Distributor.                              | `1`       |
| observability_config.cortex.enable                               | boolean | Required          | enable cortex for observability setup                                | `false`   |
| observability_config.cortex.ingester.autoscaling                 | boolean | Optional          | Enable autoscaling for Ingester.                                     | `true`    |
| observability_config.cortex.ingester.max_cpu                     | string  | Optional          | Maximum CPU allocated for each Ingester replica.                     | `null`    |
| observability_config.cortex.ingester.max_memory                  | string  | Optional          | Maximum memory allocated for each Ingester replica.                  | `null`    |
| observability_config.cortex.ingester.max_replicas                | number  | Optional          | Maximum number of Ingester replicas during autoscaling.              | `100`     |
| observability_config.cortex.ingester.memory_utilization          | number  | Optional          | Memory utilization threshold for autoscaling.                        | `""`      |
| observability_config.cortex.ingester.min_cpu                     | string  | Optional          | Minimum CPU allocated for each Ingester replica.                     | `null`    |
| observability_config.cortex.ingester.min_memory                  | string  | Optional          | Minimum memory allocated for each Ingester replica.                  | `null`    |
| observability_config.cortex.ingester.persistence_volume.size     | string  | Optional          | Size of the persistence volume for the for ingester.                 | `20Gi`    |
| observability_config.cortex.ingester.min_replicas                | number  | Optional          | Minimum number of Ingester replicas during autoscaling.              | `2`       |
| observability_config.cortex.ingester.replicas                    | number  | Optional          | Number of replicas for the Ingester.                                 | `1`       |
| observability_config.cortex.limits.ingestion_burst_size          | number  | Optional          | Maximum burst size for ingestion.                                    | `500000`  |
| observability_config.cortex.limits.ingestion_rate                | number  | Optional          | Maximum ingestion rate.                                              | `250000`  |
| observability_config.cortex.limits.max_fetched_chunks_per_query  | number  | Optional          | Maximum fetched chunks p er query (0 for unlimited).                 | `3000000` |
| observability_config.cortex.limits.max_series_per_metric         | number  | Optional          | Maximum series per metric (0 for unlimited).                         | `0`       |
| observability_config.cortex.limits.max_series_per_user           | number  | Optional          | Maximum series per user (0 for unlimited).                           | `0`       |
| observability_config.cortex.memcached_blocks.enable              | boolean | Optional          | Enable the Memcached Blocks component.                               | `true`    |
| observability_config.cortex.memcached_blocks.max_cpu             | string  | Optional          | Maximum CPU allocated for each Memcached Blocks replica.             | `null`    |
| observability_config.cortex.memcached_blocks.max_memory          | string  | Optional          | Maximum memory allocated for each Memcached Blocks replica.          | `null`    |
| observability_config.cortex.memcached_blocks.min_cpu             | string  | Optional          | Minimum CPU allocated for each Memcached Blocks replica.             | `null`    |
| observability_config.cortex.memcached_blocks.min_memory          | string  | Optional          | Minimum memory allocated for each Memcached Blocks replica.          | `null`    |
| observability_config.cortex.memcached_blocks_index.enable        | boolean | Optional          | Enable the Memcached Blocks Index component.                         | `true`    |
| observability_config.cortex.memcached_blocks_index.max_cpu       | string  | Optional          | Maximum CPU allocated for each Memcached Blocks Index replica.       | `null`    |
| observability_config.cortex.memcached_blocks_index.max_memory    | string  | Optional          | Maximum memory allocated for each Memcached Blocks Index replica.    | `null`    |
| observability_config.cortex.memcached_blocks_index.min_cpu       | string  | Optional          | Minimum CPU allocated for each Memcached Blocks Index replica.       | `null`    |
| observability_config.cortex.memcached_blocks_index.min_memory    | string  | Optional          | Minimum memory allocated for each Memcached Blocks Index replica.    | `null`    |
| observability_config.cortex.memcached_blocks_metadata.enable     | boolean | Optional          | Enable the Memcached Blocks Metadata component.                      | `true`    |
| observability_config.cortex.memcached_blocks_metadata.max_cpu    | string  | Optional          | Maximum CPU allocated for each Memcached Blocks Metadata replica.    | `null`    |
| observability_config.cortex.memcached_blocks_metadata.max_memory | string  | Optional          | Maximum memory allocated for each Memcached Blocks Metadata replica. | `null`    |
| observability_config.cortex.memcached_blocks_metadata.min_cpu    | string  | Optional          | Minimum CPU allocated for each Memcached Blocks Metadata replica.    | `null`    |
| observability_config.cortex.memcached_blocks_metadata.min_memory | string  | Optional          | Minimum memory allocated for each Memcached Blocks Metadata replica. | `null`    |
| observability_config.cortex.memcached_frontend.enable            | boolean | Optional          | Enable the Memcached Frontend component.                             | `true`    |
| observability_config.cortex.memcached_frontend.max_cpu           | string  | Optional          | Maximum CPU allocated for each Memcached Frontend replica.           | `null`    |
| observability_config.cortex.memcached_frontend.max_memory        | string  | Optional          | Maximum memory allocated for each Memcached Frontend replica.        | `null`    |
| observability_config.cortex.memcached_frontend.min_cpu           | string  | Optional          | Minimum CPU allocated for each Memcached Frontend replica.           | `null`    |
| observability_config.cortex.memcached_frontend.min_memory        | string  | Optional          | Minimum memory allocated for each Memcached Frontend replica.        | `null`    |
| observability_config.cortex.query_frontend.enable                | boolean | Optional          | Enable the Query Frontend component.                                 | `true`    |
| observability_config.cortex.query_frontend.replicas              | number  | Optional          | Number of replicas for the Query Frontend.                           | `4`       |
| observability_config.cortex.querier.autoscaling                  | boolean | Optional          | Enable autoscaling for Querier.                                      | `true`    |
| observability_config.cortex.querier.cpu_utilization              | number  | Optional          | CPU utilization threshold for autoscaling.                           | `""`      |
| observability_config.cortex.querier.max_cpu                      | string  | Optional          | Maximum CPU allocated for each Querier replica.                      | `null`    |
| observability_config.cortex.querier.max_memory                   | string  | Optional          | Maximum memory allocated for each Querier replica.                   | `null`    |
| observability_config.cortex.querier.max_replicas                 | number  | Optional          | Maximum number of Querier replicas during autoscaling.               | `20`      |
| observability_config.cortex.querier.memory_utilization           | number  | Optional          | Memory utilization threshold for autoscaling.                        | `""`      |
| observability_config.cortex.querier.min_cpu                      | string  | Optional          | Minimum CPU allocated for each Querier replica.                      | `null`    |
| observability_config.cortex.querier.min_memory                   | string  | Optional          | Minimum memory allocated for each Querier replica.                   | `null`    |
| observability_config.cortex.querier.min_replicas                 | number  | Optional          | Minimum number of Querier replicas during autoscaling.               | `2`       |
| observability_config.cortex.querier.replicas                     | number  | Optional          | Number of replicas for the Querier.                                  | `1`       |
| observability_config.cortex.query_range.memcached_client_timeout | string  | Optional          | query range memcached_client_timeout                                 | `"30s"`   |
| observability_config.cortex.storegateway.min_memory              | string  | Optional          | Minimum memory allocated for each Store Gateway replica.             | `null`    | 
| observability_config.cortex.storegateway.min_cpu                 | string  | Optional          | Minimum CPU allocated for each Store Gateway replica.                | `null`    | 
| observability_config.cortex.storegateway.max_memory              | string  | Optional          | Maximum memory allocated for each Store Gateway replica.             | `null`    |
| observability_config.cortex.storegateway.max_cpu                 | string  | Optional          | Maximum CPU allocated for each Store Gateway replica.                | `null`    |
| observability_config.cortex.storegateway.persistence_volume.size | string  | Optional          | Size of the persistence volume for the Store Gateway.                | `"500Gi"` |
| observability_config.cortex.storegateway.replicas                | number  | Optional          | Number of replicas for the Store Gateway.                            | `1`       | 
| observability_config.cortex.storegateway.replication_factor      | number  | Optional          | Replication factor for the Store Gateway.                            | `3`       | 

#### Mimir

| <div style="width:100px">inputs</div>                                 | Type    | Required/Optional | <div style="width:100px">Description</div>               | Default   |
|:----------------------------------------------------------------------|:--------|:------------------|----------------------------------------------------------|:----------|
| observability_config.mimir.compactor.max_cpu                          | string  | Optional          | Maximum CPU allocated for each Compactor replica.        | `null`    |
| observability_config.mimir.compactor.max_memory                       | string  | Optional          | Maximum memory allocated for each Compactor replica.     | `null`    |
| observability_config.mimir.compactor.min_cpu                          | string  | Optional          | Minimum CPU allocated for each Compactor replica.        | `null`    |
| observability_config.mimir.compactor.min_memory                       | string  | Optional          | Minimum memory allocated for each Compactor replica.     | `null`    |
| observability_config.mimir.compactor.persistence_volume.enable        | boolean | Optional          | Enable persistence volume for the Compactor.             | `true`    |
| observability_config.mimir.compactor.persistence_volume.size          | string  | Optional          | Size of the persistence volume for the Compactor.        | `"20Gi"`  |
| observability_config.mimir.compactor.replicas                         | number  | Optional          | Number of replicas for the Compactor.                    | `1`       |
| observability_config.mimir.distributor.max_cpu                        | string  | Optional          | Maximum CPU allocated for each Distributor replica.      | `null`    |
| observability_config.mimir.distributor.max_memory                     | string  | Optional          | Maximum memory allocated for each Distributor replica.   | `null`    |
| observability_config.mimir.distributor.min_cpu                        | string  | Optional          | Minimum CPU allocated for each Distributor replica.      | `null`    |
| observability_config.mimir.distributor.min_memory                     | string  | Optional          | Minimum memory allocated for each Distributor replica.   | `null`    |
| observability_config.mimir.distributor.replicas                       | number  | Optional          | Number of replicas for the Distributor.                  | `1`       |
| observability_config.mimir.enable                                     | boolean | Required          | enable mimir for observability setup                     | `false`   |
| observability_config.mimir.ingester.max_cpu                           | string  | Optional          | Maximum CPU allocated for each Ingester replica.         | `null`    |
| observability_config.mimir.ingester.max_memory                        | string  | Optional          | Maximum memory allocated for each Ingester replica.      | `null`    |
| observability_config.mimir.ingester.min_cpu                           | string  | Optional          | Minimum CPU allocated for each Ingester replica.         | `null`    |
| observability_config.mimir.ingester.min_memory                        | string  | Optional          | Minimum memory allocated for each Ingester replica.      | `null`    |
| observability_config.mimir.ingester.persistence_volume.size           | string  | Optional          | Size of the persistence volume for the for ingester.     | `20Gi`    |
| observability_config.mimir.ingester.replicas                          | number  | Optional          | Number of replicas for the Ingester.                     | `2`       |
| observability_config.mimir.limits.ingestion_burst_size                | number  | Optional          | Maximum burst size for ingestion.                        | `500000`  |
| observability_config.mimir.limits.ingestion_rate                      | number  | Optional          | Maximum ingestion rate.                                  | `250000`  |
| observability_config.mimir.limits.max_fetched_chunks_per_query        | number  | Optional          | Maximum fetched chunks per query (0 for unlimited).      | `3000000` |
| observability_config.mimir.limits.max_cache_freshness                 | string  | Optional          | Maximum cache freshness per query                        | `24h`     |
| observability_config.mimir.limits.max_outstanding_requests_per_tenant | number  | Optional          | Maximum outstanding request per tenant                   | `1000`    |
| observability_config.mimir.query_frontend.replicas                    | number  | Optional          | Number of replicas for the Query Frontend.               | `1`       |
| observability_config.mimir.querier.max_cpu                            | string  | Optional          | Maximum CPU allocated for each Querier replica.          | `null`    |
| observability_config.mimir.querier.max_memory                         | string  | Optional          | Maximum memory allocated for each Querier replica.       | `null`    |
| observability_config.mimir.querier.min_cpu                            | string  | Optional          | Minimum CPU allocated for each Querier replica.          | `null`    |
| observability_config.mimir.querier.min_memory                         | string  | Optional          | Minimum memory allocated for each Querier replica.       | `null`    |
| observability_config.mimir.querier.replicas                           | number  | Optional          | Number of replicas for the Querier.                      | `3`       |
| observability_config.mimir.storegateway.min_memory                    | string  | Optional          | Minimum memory allocated for each Store Gateway replica. | `null`    | 
| observability_config.mimir.storegateway.min_cpu                       | string  | Optional          | Minimum CPU allocated for each Store Gateway replica.    | `null`    | 
| observability_config.mimir.storegateway.max_memory                    | string  | Optional          | Maximum memory allocated for each Store Gateway replica. | `null`    |
| observability_config.mimir.storegateway.max_cpu                       | string  | Optional          | Maximum CPU allocated for each Store Gateway replica.    | `null`    |
| observability_config.mimir.storegateway.persistence_volume.size       | string  | Optional          | Size of the persistence volume for the Store Gateway.    | `"500Gi"` |
| observability_config.mimir.storegateway.replicas                      | number  | Optional          | Number of replicas for the Store Gateway.                | `1`       | 
| observability_config.mimir.storegateway.replication_factor            | number  | Optional          | Replication factor for the Store Gateway.                | `3`       | 

#### Tempo
| inputs                                                                          | Type         | Required/Optional | <div style="width:400px">Description</div>                 | Default |
|---------------------------------------------------------------------------------|--------------|-------------------|------------------------------------------------------------|---------|
| observability_config.tempo.distributor.autoscaling                              | boolean      | Optional          | Enable autoscaling for Distributor.                        | `true`  |
| observability_config.tempo.distributor.cpu_utilization                          | number       | Optional          | CPU utilization threshold for autoscaling.                 | `""`    |
| observability_config.tempo.distributor.max_cpu                                  | string       | Optional          | Maximum CPU allocated for each Distributor replica.        | `null`  |
| observability_config.tempo.distributor.max_memory                               | string       | Optional          | Maximum memory allocated for each Distributor replica.     | `null`  |
| observability_config.tempo.distributor.max_replicas                             | number       | Optional          | Maximum number of Distributor replicas during autoscaling. | `30`    |
| observability_config.tempo.distributor.memory_utilization                       | number       | Optional          | Memory utilization threshold for autoscaling.              | `""`    |
| observability_config.tempo.distributor.min_cpu                                  | string       | Optional          | Minimum CPU allocated for each Distributor replica.        | `null`  |
| observability_config.tempo.distributor.min_memory                               | string       | Optional          | Minimum memory allocated for each Distributor replica.     | `750Mi` |
| observability_config.tempo.distributor.min_replicas                             | number       | Optional          | Minimum number of Distributor replicas during autoscaling. | `2`     |
| observability_config.tempo.distributor.replicas                                 | number       | Optional          | Number of replicas for the Distributor.                    | `1`     |
| observability_config.tempo.enable                                               | boolean      | Required          | enable tempo for observability setup                       | `false` |
| observability_config.tempo.ingester.autoscaling                                 | boolean      | Optional          | Enable autoscaling for Ingester.                           | `true`  |
| observability_config.tempo.ingester.cpu_utilization                             | number       | Optional          | CPU utilization threshold for autoscaling.                 | `""`    |
| observability_config.tempo.ingester.max_cpu                                     | string       | Optional          | Maximum CPU allocated for each Ingester replica.           | `null`  |
| observability_config.tempo.ingester.max_memory                                  | string       | Optional          | Maximum memory allocated for each Ingester replica.        | `null`  |
| observability_config.tempo.ingester.max_replicas                                | number       | Optional          | Maximum number of Ingester replicas during autoscaling.    | `30`    |
| observability_config.tempo.ingester.memory_utilization                          | number       | Optional          | Memory utilization threshold for autoscaling.              | `""`    |
| observability_config.tempo.ingester.min_cpu                                     | string       | Optional          | Minimum CPU allocated for each Ingester replica.           | `null`  |
| observability_config.tempo.ingester.min_memory                                  | string       | Optional          | Minimum memory allocated for each Ingester replica.        | `1Gi`   |
| observability_config.tempo.ingester.min_replicas                                | number       | Optional          | Minimum number of Ingester replicas during autoscaling.    | `2`     |
| observability_config.tempo.ingester.replicas                                    | number       | Optional          | Number of replicas for the Ingester.                       | `1`     |
| observability_config.tempo.queryfrontend.replicas                               | number       | Optional          | Number of replicas for the Query Frontend.                 | `1`     |
| observability_config.tempo.querier.replicas                                     | number       | Optional          | Number of replicas for the Querier.                        | `1`     |
| observability_config.tempo.metrics_generator.enable                             | bool         | Optional          | Enable metrics generator for tempo datasource              | `false` |
| observability_config.tempo.metrics_generator.replicas                           | number       | Optional          | Number of replicas for the metrics generator.              | `1`     |
| observability_config.tempo.metrics_generator.service_graphs_max_items           | number       | Optional          | Minimum memory allocated for each Ingester replica.        | `30000` |
| observability_config.tempo.metrics_generator.service_graphs_wait                | string       | Optional          | Minimum number of Ingester replicas during autoscaling.    | `30s`   |
| observability_config.tempo.metrics_generator.remote_write_flush_deadline        | string       | Optional          | Remote write storage flush deadline                        | `2m`    |
| observability_config.tempo.metrics_generator.remote_write                       | list(object) | Optional          | Prometheus remote write configs for service graph metrics  | `null`  |
| observability_config.tempo.metrics_generator.metrics_ingestion_time_range_slack | string       | Optional          | Metrics ingestion time range slack                         | `40s`   |

### Fluent Bit Configuration

| Key                            | Type    | Required/Optional | Description                                          | Default |
|--------------------------------|---------|-------------------|------------------------------------------------------|---------|
| fluent_bit.enable               | string  | Required          | Enable Fluent Bit                                   | null    |
| fluent_bit.loki                 | list    | Optional          | Loki configuration                                   | null    |
| fluent_bit.loki.host            | string  | Required          | Loki host                                            | null    |
| fluent_bit.loki.tenant_id       | string  | Optional          | Tenant ID for Loki                                  | null    |
| fluent_bit.loki.labels          | string  | Required          | Labels for Loki                                     | null    |
| fluent_bit.loki.port            | number  | Optional          | Port for Loki                                        | null    |
| fluent_bit.loki.tls             | string  | Optional          | TLS configuration for Loki                          | null    |
| fluent_bit.http                 | list    | Optional          | HTTP configuration                                   | null    |
| fluent_bit.http.host            | string  | Required          | HTTP host                                            | null    |
| fluent_bit.http.port            | number  | Optional          | Port for HTTP                                        | null    |
| fluent_bit.http.uri             | string  | Optional          | URI for HTTP                                         | null    |
| fluent_bit.http.headers         | list    | Optional          | HTTP headers                                         | null    |
| fluent_bit.http.headers.key     | string  | Required          | Header key                                           | null    |
| fluent_bit.http.headers.value   | string  | Required          | Header value                                         | null    |
| fluent_bit.http.tls             | string  | Optional          | TLS configuration for HTTP                          | null    |
| fluent_bit.http.tls_verify      | string  | Optional          | TLS verification for HTTP                           | null    |
| fluent_bit.splunk               | list    | Optional          | Splunk configuration                                 | null    |
| fluent_bit.splunk.host          | string  | Required          | Splunk host                                          | null    |
| fluent_bit.splunk.token         | string  | Required          | Splunk token                                         | null    |
| fluent_bit.splunk.port          | number  | Optional          | Port for Splunk                                      | null    |
| fluent_bit.splunk.tls           | string  | Optional          | TLS configuration for Splunk                        | null    |
| fluent_bit.splunk.tls_verify    | string  | Optional          | TLS verification for Splunk                         | null    |