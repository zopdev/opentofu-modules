# AWS EKS Terraform module

The `eks` module contains all resources that is required for creating an AWS EKS cluster, worker-nodes, domain configuration, prometheus/grafana setup etc.
This module is the root module of all the other modules such as db, redis, observability etc.

## Values

| Inputs                    | Type         | Required/Optional | <div style="width:400px">Description</div>                                                                | Default                                     |
|---------------------------|--------------|-------------------|-----------------------------------------------------------------------------------------------------------|---------------------------------------------|
| app_admins                | list(string) | Optional          | List of users who will have admin access to cluster                                                       | `[]`                                        | 
| app_editors               | list(string) | Optional          | List of users who will have editor access to cluster                                                      | `[]`                                        | 
| app_env                   | string       | Required          | Application deployment environment                                                                        | `""`                                        | 
| app_name                  | string       | Required          | Name of the cluster                                                                                       | `""`                                        | 
| app_namespaces            | map(object)  | Optional          | Details for setting up different types of alerts at namespace level                                       | `{}`                                        | 
| app_region                | string       | Required          | Cloud region to deploy resources                                                                          | `""`                                        | 
| app_viewers               | list(string) | Optional          | List of users who will have viewer access to cluster                                                      | `[]`                                        | 
| app_private_subnets       | list(string) | Required          | Private subnets where eks cluster nodes will be put in                                                    | `nil`                                       |
| app_public_subnets        | list(string) | Required          | Public subnets where eks cluster nodes will be put in                                                     | `[]`                                        |
| appd_accesskey            | string       | Optional          | AppDynamics Accesskey                                                                                     | `""`                                        | 
| appd_account              | string       | Optional          | AppDynamics Account                                                                                       | `""`                                        | 
| appd_controller_url       | string       | Optional          | AppDynamics Controller URL                                                                                | `""`                                        |
| appd_password             | string       | Optional          | AppDynamics Password                                                                                      | `""`                                        | 
| appd_user                 | string       | Optional          | AppDynamics Username                                                                                      | `""`                                        | 
| cluster_alert_thresholds  | object       | Optional          | Cluster alerts threshold configuration                                                                    | For default values, [click here](./vars.tf) | 
| cluster_alert_webhooks    | list(object) | Optional          | Details for setting up of different types of alerts at cluster level ,for example,[click here](./vars.tf) | `[]`                                        | 
| cert_issuer_env           | string       | Optional          | Environment (prod or stage) to be used for LetsEncrypt Certificate Issuer                                 | `stage`                                     | 
| common_tags               | map(string)  | Optional          | Additional tags for merging with common tags for resources                                      | `{}`                                        | 
| custom_inbound_ip_range   | list         | Optional          | List of custom ip range that are allowed to access services on EKS cluster                                | `[]`                                        | 
| db_subnets                | list(string) | Required          | Subnets IDs the persistent apps are going to use                                                          | `[]`                                        |
| domain_name               | string       | Required          | Cloud DNS host name for the service                                                                       | `""`                                        | 
| grafana_configs           | object       | Optional          | Grafana related configuration                                                                             | `null`                                      | 
| grafana_enabled           | string       | Optional          | Enable the creation of grafana or not                                                                     | `false`                                     |
| kafka                     | map(object)  | Optional          | Map of inputs for Kafka configuration                                                                     | `{}`                                        |
| kube_node_count_max       | number       | Optional          | The max number of nodes for the kubernetes cluster                                                        | `4`                                         | 
| kube_node_count_min       | number       | Optional          | The max number of nodes for the kubernetes cluster                                                        | `2`                                         | 
| kong_config               | any          | Optional          | Map for consumers, for example configuration, [click here](./vars.tf)                                     | `{}`                                        |
| Kong_enterprise_enabled   | bool         | Optional          | Kong enterprise is enabled or not                                                                         | `false`                                     |
| kong_whitelist_cidr       | string       | Optional          | Whitelist cidr address for kong manager,Grafana and admin api                                             | `103.245.47.20/32`                          |
| moogsoft_endpoint_api_key | string       | Optional          | Moogsoft API key to configure your third-party system to send data to Moogsoft                            | `""`                                        | 
| moogsoft_username         | string       | Optional          | Username for moogsoft authentication                                                                      | `""`                                        | 
| observability_suffix      | string       | Required          | To add a suffix to Storage Buckets in Observability Cluster                                               | ""                                          |
| prometheus_disk_size      | number       | Optional          | Prometheus db disk size in GB                                                                             | `50`                                        |
| provider_id               | string       | Required          | AWS account profile name                                                                                  | `""`                                        |
| provisioner               | string       | Optional          | Provisioner being used to setup Infra                                                                     | `zop-dev`                                   |
| public_app                | bool         | Optional          | whether application deploy on public ALB on port 80                                                       | `false`                                     |
| public_ingress            | string       | Optional          | Whether ingress is public or not                                                                          | `false`                                     |
| rancher_import_enabled    | bool         | Optional          | rancher import eks clusters enabled.                                                                      | `true`                                      |
| worker_ami_config         | object       | Optional          | Object of worker_ami_config inputs                                                                        | For default values, [click here](./vars.tf) |

#### subnets
| Inputs            | Type         | Required/Optional | Description                                  | Default |
|-------------------|--------------|-------------------|----------------------------------------------|---------|
| vpc_prefix        | string       | Required          | Prefix for the VPC                          | `""`    |
| private_subnets   | list(string) | Required          | List of private subnet IDs                   | `[]`    |
| public_subnets    | list(string) | Required          | List of public subnet IDs                    | `[]`    |
| db_subnets        | list(string) | Required          | List of subnet IDs used by the database      | `[]`    |

#### user_access
| Inputs        | Type               | Required/Optional | Description                                               | Default |
|---------------|--------------------|-------------------|-----------------------------------------------------------|---------|
| app_admins    | list(string)       | Optional          | List of users with admin access to the cluster           | `[]`    |
| app_viewers   | list(string)       | Optional          | List of users with viewer access to the cluster          | `[]`    |
| app_editors   | list(string)       | Optional          | List of users with editor access to the cluster          | `[]`    |

#### grafana_configs
| Inputs          | Type         | Required/Optional | <div style="width:400px">Description</div>                                                                    | Default |
|-----------------|--------------|-------------------|---------------------------------------------------------------------------------------------------------------|---------|
| datasource_list | list(string) | Optional          | List of grafana data sources                                                                                  | `[]`    |
| domains         | list(string) | Optional          | List of domains to restrict the authentication to specific users based on the domains of the email addresses. | `[]`    |
| enable_sso      | bool         | Optional          | This specifies whether user requires Google SSO to login or not                                               | `false` |

#### app_namespaces
| Inputs             | Type                                                                                       | Required/Optional | Description                                                       | Default |
|--------------------|--------------------------------------------------------------------------------------------|-------------------|-------------------------------------------------------------------|---------|
| alert_webhooks     | list(object)            | Optional          | List of alert webhooks configurations                              | `{}`    |
| admins             | list(string)                                                                              | Optional          | List of users with admin access to non-system resources in the namespace | `{}`    |
| editors            | list(string)                                                                              | Optional          | List of users with editor access to non-system resources in the namespace | `{}`    |
| viewers            | list(string)                                                                              | Optional          | List of users with viewer access to non-system resources in the namespace | `{}`    |

#### alert_webhooks
| Inputs | Type                 | Required/Optional | Description                                                                 | Default |
|--------|----------------------|-------------------|-----------------------------------------------------------------------------|---------|
| type   | string               | Required          | Type of alert webhook.                         |         |
| data   | string               | Required          | URL or endpoint for the alert webhook                                       |         |
| labels | map(string)          | Optional          | Optional labels for the alert webhook configuration                          | `{}`    |

#### node_config
| Inputs      | Type   | Required/Optional | Description                        | Default |
|-------------|--------|-------------------|------------------------------------|---------|
| node_type   | string | Required          | Type of the node                   | `""`    |
| min_count   | number | Required          | Minimum number of nodes            |      |
| max_count   | number | Required          | Maximum number of nodes    

#### cluster_alert_webhooks
| Inputs | Type         | Required/Optional | Description                        | Default |
|--------|--------------|-------------------|------------------------------------|---------|
| type   | string       | Required          | Type of alert webhook              | `""`    |
| data   | string       | Required          | Data for the alert webhook         | `""`    |

#### kafka
| Inputs  | Type         | Required/Optional | Description                        | Default |
|---------|--------------|-------------------|------------------------------------|---------|
| topics  | list(string) | Optional          | List of Kafka topics               | `[]`    |

#### worker_ami_config
| Inputs  | Type   | Required/Optional | Description                                           | Default                  |
|---------|--------|-------------------|-------------------------------------------------------|--------------------------|
| owner_id| string | Required          | AWS owner ID for the AMI                              | `"amazon"`               |
| name    | string | Required          | Name of the AMI                                      | `"amazon-eks-node-1.25-v20230406"` |


#### cluster_alert_thresholds
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
| container_cpu_utilization             | number  | Optional          | Container CPU utilization threshold         | `80`    |
| container_memory_utilization          | number  | Optional          | Container memory utilization threshold      | `80`    |
| container_memory_working_set          | number  | Optional          | Container memory working set threshold      | `80`    |
| api_server_availability_threshold     | number  | Optional          | API server availability threshold           | `99`    |
| etcd_io_rate_threshold                | number  | Optional          | ETCD IO rate threshold                      | `100`   |
| etcd_disk_utilization_threshold       | number  | Optional          | ETCD disk utilization threshold             | `80`    |

#### custom_secrets_name_list
| Inputs              | Type  | Required/Optional | Description                                               | Default |
|---------------------|-------|-------------------|-----------------------------------------------------------|---------|
| secrets             | list  | Required          | List of AWS secrets that were manually created by prefixing cluster name and environment | `[]`    |

#### observability_config
| Inputs                                        | Type   | Required/Optional | Description                                              | Default |
|-----------------------------------------------|--------|-------------------|----------------------------------------------------------|---------|
| suffix                                        | string | Optional          | Suffix for observability configuration                  | `null`  |
|  prometheus    | object | Optional          | Prometheus configuration                         | null    |
|  grafana       | object | Optional          | Grafana configuration                            | null    |
|  kubernetes_event_exporter       | object | Optional          | Kubernetes event exporter configuration configuration                            | null    |
|  loki          | object | Optional          | Loki configuration                               | null    |
|  cortex        | object | Optional          | Cortex configuration                             | null    |
|  mimir         | object | Optional          | Mimir configuration                              | null    |
|  tempo         | object | Optional          | Tempo configuration                              | null    |

### Observability Config - Prometheus

| Key                       | Type     | Required/Optional | Description                       | Default |
|---------------------------|----------|-------------------|-----------------------------------|---------|
| prometheus.version        | string   | Optional          | Prometheus version                | null    |
| prometheus.enable         | bool     | Required          | Enable Prometheus                 | null    |
| prometheus.persistence    | object   | Optional          | Prometheus persistence settings   | null    |
| prometheus.persistence.disk_size          | string   | Optional          | Disk size for persistence          | null    |
| prometheus.persistence.retention_size     | string   | Optional          | Retention size for persistence     | null    |
| prometheus.persistence.retention_duration | string   | Optional          | Retention duration for persistence | null    |
| prometheus.remote_write   | list     | Optional          | Remote write settings             | null    |
| prometheus.remote_write.host             | string   | Optional          | Host for remote write             | null    |
| prometheus.remote_write.header           | object   | Optional          | Header settings for remote write  | null    |
| prometheus.remote_write.header.key       | string   | Optional          | Key for remote write header       | null    |
| prometheus.remote_write.header.value     | string   | Optional          | Value for remote write header     | null    |

### Observability Config - Grafana

| Key                            | Type     | Required/Optional | Description                       | Default |
|--------------------------------|----------|-------------------|-----------------------------------|---------|
| grafana.version                | string   | Optional          | Grafana version                   | null    |
| grafana.enable                 | bool     | Required          | Enable Grafana                    | null    |
| grafana.url                    | string   | Optional          | URL for Grafana                   | null    |
| grafana.min_replica            | number   | Optional          | Minimum number of replicas        | null    |
| grafana.max_replica            | number   | Optional          | Maximum number of replicas        | null    |
| grafana.request_memory         | string   | Optional          | Memory request for Grafana        | null    |
| grafana.request_cpu            | string   | Optional          | CPU request for Grafana           | null    |
| grafana.dashboard              | object   | Optional          | Dashboard configuration           | null    |
| grafana.dashboard.limit_memory | string   | Optional          | Memory limit for dashboard        | null    |
| grafana.dashboard.limit_cpu    | string   | Optional          | CPU limit for dashboard           | null    |
| grafana.dashboard.request_memory | string | Optional          | Memory request for dashboard      | null    |
| grafana.dashboard.request_cpu  | string   | Optional          | CPU request for dashboard         | null    |
| grafana.datasource             | object   | Optional          | Datasource configuration          | null    |
| grafana.datasource.limit_memory| string   | Optional          | Memory limit for datasource       | null    |
| grafana.datasource.limit_cpu   | string   | Optional          | CPU limit for datasource          | null    |
| grafana.datasource.request_memory | string | Optional         | Memory request for datasource     | null    |
| grafana.datasource.request_cpu | string   | Optional          | CPU request for datasource        | null    |
| grafana.persistence            | object   | Optional          | Persistence configuration         | null    |
| grafana.persistence.type       | string   | Optional          | Persistence type                  | null    |
| grafana.persistence.disk_size  | string   | Optional          | Disk size for persistence         | null    |
| grafana.persistence.deletion_protection | string | Optional    | Deletion protection for persistence | null  |
| grafana.configs                | object   | Optional          | Additional configurations         | null    |
| grafana.configs.datasource_list| map(any) | Optional          | List of datasources               | null    |
| grafana.configs.domains        | list     | Optional          | List of domains                   | null    |
| grafana.configs.enable_sso     | bool     | Optional          | Enable Single Sign-On (SSO)       | null    |

### Observability Config - Kubernetes Event Exporter

| Key                                        | Type     | Required/Optional | Description                                   | Default |
|--------------------------------------------|----------|-------------------|-----------------------------------------------|---------|
| kubernetes_event_exporter.enable           | bool     | Required          | Enable Kubernetes Event Exporter              | null    |
| kubernetes_event_exporter.log_level        | string   | Optional          | Log level                                     | null    |
| kubernetes_event_exporter.max_event_age_second | string | Optional          | Maximum event age in seconds                  | null    |
| kubernetes_event_exporter.loki_receivers   | list     | Optional          | List of Loki receivers                        | null    |
| kubernetes_event_exporter.loki_receivers.name | string | Required          | Name of the Loki receiver                     | null    |
| kubernetes_event_exporter.loki_receivers.url | string | Required          | URL of the Loki receiver                      | null    |
| kubernetes_event_exporter.loki_receivers.header | object | Optional          | Header configuration for Loki receiver        | null    |
| kubernetes_event_exporter.loki_receivers.header.key | string | Optional        | Key for the header                            | null    |
| kubernetes_event_exporter.loki_receivers.header.value | string | Optional       | Value for the header                          | null    |
| kubernetes_event_exporter.webhook_receivers | list    | Optional          | List of webhook receivers                     | null    |
| kubernetes_event_exporter.webhook_receivers.name | string | Required         | Name of the webhook receiver                  | null    |
| kubernetes_event_exporter.webhook_receivers.type | string | Required         | Type of the webhook receiver                  | null    |
| kubernetes_event_exporter.webhook_receivers.url | string | Required          | URL of the webhook receiver                   | null    |
| kubernetes_event_exporter.webhook_receivers.header | object | Optional        | Header configuration for webhook receiver     | null    |
| kubernetes_event_exporter.webhook_receivers.header.key | string | Optional       | Key for the header                            | null    |
| kubernetes_event_exporter.webhook_receivers.header.value | string | Optional      | Value for the header                          | null    |
| kubernetes_event_exporter.resource         | object   | Optional          | Resource configuration                        | null    |
| kubernetes_event_exporter.resource.limit_cpu | string  | Optional          | CPU limit                                     | null    |
| kubernetes_event_exporter.resource.limit_memory | string | Optional          | Memory limit                                  | null    |
| kubernetes_event_exporter.resource.request_cpu | string | Optional          | CPU request                                   | null    |
| kubernetes_event_exporter.resource.request_memory | string | Optional        | Memory request                                | null    |

### Observability Config - Loki

| Key                                                | Type     | Required/Optional | Description                                       | Default |
|----------------------------------------------------|----------|-------------------|---------------------------------------------------|---------|
| loki.enable                                        | bool     | Required          | Enable Loki                                       | null    |
| loki.enable_ingress                                | bool     | Optional          | Enable ingress for Loki                           | null    |
| loki.alerts                                        | object   | Optional          | Loki alerts configuration                         | null    |
| loki.alerts.distributor_lines_received             | string   | Optional          | Lines received by the distributor                 | null    |
| loki.alerts.distributor_bytes_received             | number   | Optional          | Bytes received by the distributor                 | null    |
| loki.alerts.distributor_appended_failures          | number   | Optional          | Append failures by the distributor                | null    |
| loki.alerts.request_errors                         | number   | Optional          | Request errors                                    | null    |
| loki.alerts.panics                                 | number   | Optional          | Panics                                            | null    |
| loki.alerts.request_latency                        | number   | Optional          | Request latency                                   | null    |
| loki.alerts.distributor_replica                    | number   | Optional          | Distributor replicas                              | null    |
| loki.alerts.ingester_replica                       | number   | Optional          | Ingester replicas                                 | null    |
| loki.alerts.querier_replica                        | number   | Optional          | Querier replicas                                  | null    |
| loki.alerts.query_frontend_replica                 | number   | Optional          | Query frontend replicas                           | null    |
| loki.alerts.compactor_replica                      | number   | Optional          | Compactor replicas                                | null    |
| loki.ingester                                      | object   | Optional          | Ingester configuration                            | null    |
| loki.ingester.replicas                             | number   | Optional          | Number of replicas                                | null    |
| loki.ingester.max_memory                           | string   | Optional          | Maximum memory                                    | null    |
| loki.ingester.min_memory                           | string   | Optional          | Minimum memory                                    | null    |
| loki.ingester.max_cpu                              | string   | Optional          | Maximum CPU                                       | null    |
| loki.ingester.min_cpu                              | string   | Optional          | Minimum CPU                                       | null    |
| loki.ingester.autoscaling                          | bool     | Optional          | Enable autoscaling                                | null    |
| loki.ingester.max_replicas                         | number   | Optional          | Maximum replicas                                  | null    |
| loki.ingester.min_replicas                         | number   | Optional          | Minimum replicas                                  | null    |
| loki.ingester.memory_utilization                   | string   | Optional          | Memory utilization                                | null    |
| loki.ingester.cpu_utilization                      | string   | Optional          | CPU utilization                                   | null    |
| loki.distributor                                   | object   | Optional          | Distributor configuration                         | null    |
| loki.distributor.replicas                          | number   | Optional          | Number of replicas                                | null    |
| loki.distributor.max_memory                        | string   | Optional          | Maximum memory                                    | null    |
| loki.distributor.min_memory                        | string   | Optional          | Minimum memory                                    | null    |
| loki.distributor.max_cpu                           | string   | Optional          | Maximum CPU                                       | null    |
| loki.distributor.min_cpu                           | string   | Optional          | Minimum CPU                                       | null    |
| loki.distributor.autoscaling                       | bool     | Optional          | Enable autoscaling                                | null    |
| loki.distributor.max_replicas                      | number   | Optional          | Maximum replicas                                  | null    |
| loki.distributor.min_replicas                      | number   | Optional          | Minimum replicas                                  | null    |
| loki.distributor.memory_utilization                | string   | Optional          | Memory utilization                                | null    |
| loki.distributor.cpu_utilization                   | string   | Optional          | CPU utilization                                   | null    |
| loki.querier                                       | object   | Optional          | Querier configuration                             | null    |
| loki.querier.replicas                              | number   | Optional          | Number of replicas                                | null    |
| loki.querier.max_unavailable                       | number   | Optional          | Maximum unavailable                               | null    |
| loki.querier.min_memory                            | string   | Optional          | Minimum memory                                    | null    |
| loki.querier.max_memory                            | string   | Optional          | Maximum memory                                    | null    |
| loki.querier.min_cpu                               | string   | Optional          | Minimum CPU                                       | null    |
| loki.querier.max_cpu                               | string   | Optional          | Maximum CPU                                       | null    |
| loki.querier.autoscaling                           | bool     | Optional          | Enable autoscaling                                | null    |
| loki.querier.max_replicas                          | number   | Optional          | Maximum replicas                                  | null    |
| loki.querier.min_replicas                          | number   | Optional          | Minimum replicas                                  | null    |
| loki.querier.memory_utilization                    | string   | Optional          | Memory utilization                                | null    |
| loki.querier.cpu_utilization                       | string   | Optional          | CPU utilization                                   | null    |
| loki.query_frontend                                | object   | Optional          | Query frontend configuration                      | null    |
| loki.query_frontend.replicas                       | number   | Optional          | Number of replicas                                | null    |
| loki.query_frontend.min_memory                     | string   | Optional          | Minimum memory                                    | null    |
| loki.query_frontend.max_memory                     | string   | Optional          | Maximum memory                                    | null    |
| loki.query_frontend.min_cpu                        | string   | Optional          | Minimum CPU                                       | null    |
| loki.query_frontend.max_cpu                        | string   | Optional          | Maximum CPU                                       | null    |
| loki.query_frontend.autoscaling                    | bool     | Optional          | Enable autoscaling                                | null    |
| loki.query_frontend.max_replicas                   | number   | Optional          | Maximum replicas                                  | null    |
| loki.query_frontend.min_replicas                   | number   | Optional          | Minimum replicas                                  | null    |
| loki.query_frontend.memory_utilization             | string   | Optional          | Memory utilization                                | null    |
| loki.query_frontend.cpu_utilization                | string   | Optional          | CPU utilization                                   | null    |

### Observability Config - Cortex

| Key                                    | Type   | Required/Optional | Description                                       | Default |
|----------------------------------------|--------|-------------------|---------------------------------------------------|---------|
| cortex.enable                          | bool   | Required          | Enable Cortex                                     | null    |
| cortex.enable_ingress                  | bool   | Optional          | Enable ingress for Cortex                        | null    |
| cortex.limits                          | object | Optional          | Cortex limits configuration                       | null    |
| cortex.limits.ingestion_rate           | number | Optional          | Ingestion rate limit                              | null    |
| cortex.limits.ingestion_burst_size     | number | Optional          | Ingestion burst size limit                        | null    |
| cortex.limits.max_series_per_metric    | number | Optional          | Max series per metric                             | null    |
| cortex.limits.max_series_per_user      | number | Optional          | Max series per user                               | null    |
| cortex.limits.max_fetched_chunks_per_query | number | Optional          | Max fetched chunks per query                      | null    |
| cortex.query_range                     | object | Optional          | Query range configuration                         | null    |
| cortex.query_range.memcached_client_timeout | string | Optional          | Memcached client timeout                          | null    |
| cortex.compactor                       | object | Optional          | Compactor configuration                           | null    |
| cortex.compactor.enable                | bool   | Optional          | Enable compactor                                  | null    |
| cortex.compactor.replicas              | number | Optional          | Number of replicas for compactor                  | null    |
| cortex.compactor.persistence_volume    | object | Optional          | Persistence volume configuration for compactor    | null    |
| cortex.compactor.persistence_volume.enable | bool | Optional          | Enable persistence volume for compactor           | null    |
| cortex.compactor.persistence_volume.size | string | Optional          | Size of persistence volume for compactor          | null    |
| cortex.compactor.min_cpu               | string | Optional          | Minimum CPU for compactor                         | null    |
| cortex.compactor.max_cpu               | string | Optional          | Maximum CPU for compactor                         | null    |
| cortex.compactor.min_memory            | string | Optional          | Minimum memory for compactor                      | null    |
| cortex.compactor.max_memory            | string | Optional          | Maximum memory for compactor                      | null    |
| cortex.ingester                        | object | Optional          | Ingester configuration                            | null    |
| cortex.ingester.replicas               | number | Optional          | Number of replicas for ingester                   | null    |
| cortex.ingester.persistence_volume     | object | Optional          | Persistence volume configuration for ingester     | null    |
| cortex.ingester.persistence_volume.size | string | Optional          | Size of persistence volume for ingester           | null    |
| cortex.ingester.min_memory             | string | Optional          | Minimum memory for ingester                       | null    |
| cortex.ingester.max_memory             | string | Optional          | Maximum memory for ingester                       | null    |
| cortex.ingester.min_cpu                | string | Optional          | Minimum CPU for ingester                          | null    |
| cortex.ingester.max_cpu                | string | Optional          | Maximum CPU for ingester                          | null    |
| cortex.ingester.autoscaling            | bool   | Optional          | Enable autoscaling for ingester                   | null    |
| cortex.ingester.max_replicas           | number | Optional          | Maximum replicas for ingester                     | null    |
| cortex.ingester.min_replicas           | number | Optional          | Minimum replicas for ingester                     | null    |
| cortex.ingester.memory_utilization     | string | Optional          | Memory utilization for ingester                   | null    |
| cortex.querier                         | object | Optional          | Querier configuration                             | null    |
| cortex.querier.replicas                | number | Optional          | Number of replicas for querier                    | null    |
| cortex.querier.min_memory              | string | Optional          | Minimum memory for querier                        | null    |
| cortex.querier.max_memory              | string | Optional          | Maximum memory for querier                        | null    |
| cortex.querier.min_cpu                 | string | Optional          | Minimum CPU for querier                           | null    |
| cortex.querier.max_cpu                 | string | Optional          | Maximum CPU for querier                           | null    |
| cortex.querier.autoscaling             | bool   | Optional          | Enable autoscaling for querier                    | null    |
| cortex.querier.max_replicas            | number | Optional          | Maximum replicas for querier                      | null    |
| cortex.querier.min_replicas            | number | Optional          | Minimum replicas for querier                      | null    |
| cortex.querier.memory_utilization      | string | Optional          | Memory utilization for querier                    | null    |
| cortex.querier.cpu_utilization         | string | Optional          | CPU utilization for querier                       | null    |
| cortex.query_frontend                  | object | Optional          | Query frontend configuration                      | null    |
| cortex.query_frontend.replicas         | number | Optional          | Number of replicas for query frontend             | null    |
| cortex.query_frontend.enable           | bool   | Optional          | Enable query frontend                             | null    |
| cortex.store_gateway                   | object | Optional          | Store gateway configuration                       | null    |
| cortex.store_gateway.replication_factor | number | Optional          | Replication factor for store gateway              | null    |
| cortex.store_gateway.replicas          | number | Optional          | Number of replicas for store gateway              | null    |
| cortex.store_gateway.persistence_volume | object | Optional          | Persistence volume configuration for store gateway | null    |
| cortex.store_gateway.persistence_volume.size | string | Optional          | Size of persistence volume for store gateway      | null    |
| cortex.store_gateway.min_memory        | string | Optional          | Minimum memory for store gateway                  | null    |
| cortex.store_gateway.min_cpu           | string | Optional          | Minimum CPU for store gateway                     | null    |
| cortex.store_gateway.max_cpu           | string | Optional          | Maximum CPU for store gateway                     | null    |
| cortex.store_gateway.max_memory        | string | Optional          | Maximum memory for store gateway                  | null    |
| cortex.memcached_frontend              | object | Optional          | Memcached frontend configuration                  | null    |
| cortex.memcached_frontend.enable       | bool   | Optional          | Enable memcached frontend                         | null    |
| cortex.memcached_frontend.min_memory   | string | Optional          | Minimum memory for memcached frontend             | null    |
| cortex.memcached_frontend.min_cpu      | string | Optional          | Minimum CPU for memcached frontend                | null    |
| cortex.memcached_frontend.max_cpu      | string | Optional          | Maximum CPU for memcached frontend                | null    |
| cortex.memcached_frontend.max_memory   | string | Optional          | Maximum memory for memcached frontend             | null    |
| cortex.memcached_blocks_index          | object | Optional          | Memcached blocks index configuration              | null    |
| cortex.memcached_blocks_index.enable   | bool   | Optional          | Enable memcached blocks index                     | null    |
| cortex.memcached_blocks_index.min_memory | string | Optional          | Minimum memory for memcached blocks index         | null    |
| cortex.memcached_blocks_index.min_cpu  | string | Optional          | Minimum CPU for memcached blocks index            | null    |
| cortex.memcached_blocks_index.max_cpu  | string | Optional          | Maximum CPU for memcached blocks index            | null    |
| cortex.memcached_blocks_index.max_memory | string | Optional          | Maximum memory for memcached blocks index         | null    |
| cortex.memcached_blocks                | object | Optional          | Memcached blocks configuration                    | null    |
| cortex.memcached_blocks.enable         | bool   | Optional          | Enable memcached blocks                           | null    |
| cortex.memcached_blocks.min_memory     | string | Optional          | Minimum memory for memcached blocks               | null    |
| cortex.memcached_blocks.min_cpu        | string | Optional          | Minimum CPU for memcached blocks                  | null    |
| cortex.memcached_blocks.max_cpu        | string | Optional          | Maximum CPU for memcached blocks                  | null    |
| cortex.memcached_blocks.max_memory     | string | Optional          | Maximum memory for memcached blocks               | null    |
| cortex.memcached_blocks_metadata       | object | Optional          | Memcached blocks metadata configuration           | null    |
| cortex.memcached_blocks_metadata.enable | bool  | Optional          | Enable memcached blocks metadata                  | null    |
| cortex.memcached_blocks_metadata.min_memory | string | Optional          | Minimum memory for memcached blocks metadata      | null    |
| cortex.memcached_blocks_metadata.min_cpu | string | Optional          | Minimum CPU for memcached blocks metadata         | null    |
| cortex.memcached_blocks_metadata.max_cpu | string | Optional          | Maximum CPU for memcached blocks metadata         | null    |
| cortex.memcached_blocks_metadata.max_memory | string | Optional          | Maximum memory for memcached blocks metadata      | null    |
| cortex.distributor                     | object | Optional          | Distributor configuration                         | null    |
| cortex.distributor.replicas            | number | Optional          | Number of replicas for distributor                | null    |
| cortex.distributor.min_memory          | string | Optional          | Minimum memory for distributor                    | null    |
| cortex.distributor.min_cpu             | string | Optional          | Minimum CPU for distributor                       | null    |
| cortex.distributor.max_cpu             | string | Optional          | Maximum CPU for distributor                       | null    |
| cortex.distributor.max_memory          | string | Optional          | Maximum memory for distributor                    | null    |
| cortex.distributor.autoscaling         | bool   | Optional          | Enable autoscaling for distributor                | null    |
| cortex.distributor.min_replicas        | number | Optional          | Minimum replicas for distributor                  | null    |
| cortex.distributor.max_replicas        | number | Optional          | Maximum replicas for distributor                  | null    |
| cortex.distributor.memory_utilization  | string | Optional          | Memory utilization for distributor                | null    |
| cortex.distributor.cpu_utilization     | string | Optional          | CPU utilization for distributor                   | null    |

### Observability Config - Tempo

| Key                                         | Type   | Required/Optional | Description                                          | Default |
|---------------------------------------------|--------|-------------------|------------------------------------------------------|---------|
| tempo.enable                               | bool   | Required          | Enable Tempo                                        | null    |
| tempo.enable_ingress                       | bool   | Optional          | Enable ingress for Tempo                            | null    |
| tempo.alerts                               | object | Optional          | Tempo alerts configuration                          | null    |
| tempo.alerts.ingester_bytes_received       | number | Optional          | Bytes received by ingester                          | null    |
| tempo.alerts.distributor_ingester_appends   | number | Optional          | Distributor ingester appends                         | null    |
| tempo.alerts.distributor_ingester_append_failures | number | Optional          | Distributor ingester append failures                 | null    |
| tempo.alerts.ingester_live_traces           | number | Optional          | Live traces by ingester                              | null    |
| tempo.alerts.distributor_spans_received     | number | Optional          | Spans received by distributor                        | null    |
| tempo.alerts.distributor_bytes_received     | number | Optional          | Bytes received by distributor                        | null    |
| tempo.alerts.ingester_blocks_flushed        | number | Optional          | Blocks flushed by ingester                           | null    |
| tempo.alerts.tempodb_blocklist              | number | Optional          | Tempodb blocklist                                    | null    |
| tempo.alerts.distributor_replica            | number | Optional          | Number of distributor replicas                       | null    |
| tempo.alerts.ingester_replica               | number | Optional          | Number of ingester replicas                          | null    |
| tempo.alerts.querier_replica                | number | Optional          | Number of querier replicas                           | null    |
| tempo.alerts.query_frontend_replica         | number | Optional          | Number of query frontend replicas                    | null    |
| tempo.alerts.compactor_replica              | number | Optional          | Number of compactor replicas                         | null    |
| tempo.max_receiver_msg_size                 | number | Optional          | Max receiver message size                           | null    |
| tempo.ingester                              | object | Optional          | Ingester configuration                               | null    |
| tempo.ingester.replicas                     | number | Optional          | Number of replicas for ingester                      | null    |
| tempo.ingester.min_memory                   | string | Optional          | Minimum memory for ingester                         | null    |
| tempo.ingester.min_cpu                      | string | Optional          | Minimum CPU for ingester                            | null    |
| tempo.ingester.max_cpu                      | string | Optional          | Maximum CPU for ingester                            | null    |
| tempo.ingester.max_memory                   | string | Optional          | Maximum memory for ingester                         | null    |
| tempo.ingester.autoscaling                  | bool   | Optional          | Enable autoscaling for ingester                     | null    |
| tempo.ingester.max_replicas                 | number | Optional          | Maximum replicas for ingester                       | null    |
| tempo.ingester.min_replicas                 | number | Optional          | Minimum replicas for ingester                       | null    |
| tempo.ingester.memory_utilization           | string | Optional          | Memory utilization for ingester                     | null    |
| tempo.ingester.cpu_utilization              | string | Optional          | CPU utilization for ingester                        | null    |
| tempo.distributor                           | object | Optional          | Distributor configuration                            | null    |
| tempo.distributor.replicas                  | number | Optional          | Number of replicas for distributor                  | null    |
| tempo.distributor.min_memory                | string | Optional          | Minimum memory for distributor                      | null    |
| tempo.distributor.min_cpu                   | string | Optional          | Minimum CPU for distributor                         | null    |
| tempo.distributor.max_cpu                   | string | Optional          | Maximum CPU for distributor                         | null    |
| tempo.distributor.max_memory                | string | Optional          | Maximum memory for distributor                      | null    |
| tempo.distributor.autoscaling               | bool   | Optional          | Enable autoscaling for distributor                  | null    |
| tempo.distributor.max_replicas              | number | Optional          | Maximum replicas for distributor                    | null    |
| tempo.distributor.min_replicas              | number | Optional          | Minimum replicas for distributor                    | null    |
| tempo.distributor.memory_utilization        | string | Optional          | Memory utilization for distributor                  | null    |
| tempo.distributor.cpu_utilization           | string | Optional          | CPU utilization for distributor                     | null    |
| tempo.querier                               | object | Optional          | Querier configuration                                | null    |
| tempo.querier.replicas                      | number | Optional          | Number of replicas for querier                      | null    |
| tempo.query_frontend                        | object | Optional          | Query frontend configuration                        | null    |
| tempo.query_frontend.replicas               | number | Optional          | Number of replicas for query frontend               | null    |
| tempo.metrics_generator                     | object | Optional          | Metrics generator configuration                     | null    |
| tempo.metrics_generator.enable              | bool   | Optional          | Enable metrics generator                            | null    |
| tempo.metrics_generator.replicas            | number | Optional          | Number of replicas for metrics generator            | null    |
| tempo.metrics_generator.service_graphs_max_items | number | Optional          | Max items for service graphs                        | null    |
| tempo.metrics_generator.service_graphs_wait | string | Optional          | Wait time for service graphs                        | null    |
| tempo.metrics_generator.remote_write_flush_deadline | string | Optional          | Remote write flush deadline                        | null    |
| tempo.metrics_generator.remote_write        | list   | Optional          | Remote write configuration                          | null    |
| tempo.metrics_generator.remote_write.host   | string | Optional          | Remote write host                                  | null    |
| tempo.metrics_generator.remote_write.header | object | Optional          | Remote write headers                                | null    |
| tempo.metrics_generator.remote_write.header.key | string | Optional          | Remote write header key                             | null    |
| tempo.metrics_generator.remote_write.header.value | string | Optional          | Remote write header value                           | null    |
| tempo.metrics_generator.metrics_ingestion_time_range_slack | string | Optional          | Metrics ingestion time range slack                  | null    |

### Fluent Bit Configuration

| Key                            | Type    | Required/Optional | Description                                          | Default |
|--------------------------------|---------|-------------------|------------------------------------------------------|---------|
| fluent_bit.enable               | string  | Required          | Enable Fluent Bit                                   | null    |
| fluent_bit.cloud_watch_enable   | string  | Required          | Enable CloudWatch integration                       | null    |
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
