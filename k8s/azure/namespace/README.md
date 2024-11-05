# Azure Namespace Terraform module

The `namespace` module contains all resources that are required for creating a namespace resources in AKS cluster. 
This module is the root module for the other modules related to `db`, `redis` etc.

## Values

| Inputs                   | Type         | Required/Optional | <div style="width:400px">Description</div>                                                            | Default |
|--------------------------|--------------|-------------------|-------------------------------------------------------------------------------------------------------|---------|
| accessibility                   | object | Optional          | The list of user access for the account setup                                               |     |
| app_env                  | string       | Required          | Application deployment environment                                                                    | `""`    |
| app_name                 | string       | Required          | Name of the Cluster                                                                                   | `""`    |
| app_region               | string       | Required          | Cloud region to deploy resources                                                                      | `""`    |
| cassandra_db             | object       | Optional          | Inputs to provision Cassandra instances                                                               | `null`  |
| cert_issuer_env             | string       | Optional          | Environment (prod or stage) to be used for LetsEncrypt Certificate Issuer                                                               | `stage`  |
| cron_jobs             | map(object)       | Optional          | Map of cron jobs to be executed within the namespace                                                               | `{}`  |
| common_tags              | map(string)  | Optional          | Additional tags for merging with common tags for resources                                  | `{}`    |
| container_name           | string       | Required          | Name of the container which store tfstate files                                                       | `""`    |
| custom_namespace_secrets | list         | Optional          | List of Azure secrets that were manually created by prefixing cluster name, environment and namespace | `{}`    |
| deploy_env | string         | Optional          | Deployment environment | `null`    |
| domain_name              | string       | Required          | Cloud DNS host name for the service                                                                   | `""`    |
| helm_charts                  | map(object) | Optional          | Helm chart installation inputs                                              | `{}`    |
| ingress_custom_domain    | map(any)     | Optional          | Map for k8 ingress for custom domain, for example configuration, [click here](./vars.tf)              | `{}`    |
| local_redis    | object     | Optional          | Inputs to provision Redis instance within the cluster as a statefulset.              | `null`    |
| namespace                  | string      | Required          | Namespace of the Services to be deployed                                            | `""`    |
| provisioner                | string      | Optional          | Provisioner being used to setup Infra                                                | `zop-dev` |
| public_ingress             | string      | Optional          | Whether ingress is public or not                                                    | `false` |
| redis                      | object      | Optional          | Inputs to provision Redis instances                                                  | `null`  |
| resource_group_name        | string      | Required          | The Azure Resource Group name in which all resources should be created              | `""`    |
| storage_account_name       | string      | Required          | The Azure Storage Account name in which data should be managed & stored in the cloud | `""`    |
| services                   | map(object) | Required          | Map of services to be deployed within the namespace. For more info, check below.    | `{}`    |
| sql_db                     | object      | Optional          | Inputs to provision SQL instance, for more information [click here](./vars.tf)      | `null`  |
| user_access                | object      | Required          | List of users who will have access to clusters                                      |         |
| vpc                       | string      | Required          | VPC the apps are going to use                                                        | `""`    |







### User Access Configuration

| Key         | Type    | Required/Optional | Description                                | Default    |
|-------------|---------|-------------------|--------------------------------------------|------------|
| admins  | list(string)    | Optional          | List of users with admin access            | `[]`         |
| viewers | list(string)    | Optional          | List of users with viewer access           | `[]`        |
| editors | list(string)    | Optional          | List of users with editor access           | `[]`         |

### Cron Jobs Configuration

| Key                              | Type    | Required/Optional | Description                                               | Default |
|----------------------------------|---------|-------------------|-----------------------------------------------------------|---------|
| repo_name                        | string  | Optional          | Repository name                                           | null    |
| acr_name                         | string  | Optional          | Azure Container Registry name                            | null    |
| acr_resource_group               | string  | Optional          | Azure resource group for the container registry          | null    |
| db_name                          | string  | Optional          | Database name                                             | null    |
| redis                            | bool    | Optional          | Enable Redis                                              | null    |
| local_redis                      | bool    | Optional          | Enable local Redis                                        | null    |
| service_account                  | string  | Optional          | Service account to be used                                | null    |
| custom_secrets                   | list    | Optional          | List of custom secrets                                    | []      |
| ingress_list                     | list    | Optional          | List of ingress configurations                            | []      |
| enable_basic_auth                | bool    | Optional          | Enable basic authentication                              | null    |
| enable_default_ingress           | bool    | Optional          | Enable default ingress configurations                     | null    |
| helm_configs                     | object  | Optional          | Helm chart configurations                                 | {}      |
| helm_configs.image_pull_secrets  | list    | Optional          | List of image pull secrets                               | []      |
| helm_configs.schedule            | string  | Required          | Cron schedule                                            | null    |
| helm_configs.suspend             | bool    | Optional          | Suspend cron job                                          | null    |
| helm_configs.concurrency_policy  | string  | Optional          | Concurrency policy                                       | null    |
| helm_configs.http_port           | string  | Optional          | HTTP port                                                 | null    |
| helm_configs.metrics_port        | string  | Optional          | Metrics port                                              | null    |
| helm_configs.min_cpu             | string  | Optional          | Minimum CPU                                              | null    |
| helm_configs.min_memory          | string  | Optional          | Minimum memory                                           | null    |
| helm_configs.max_cpu             | string  | Optional          | Maximum CPU                                              | null    |
| helm_configs.max_memory          | string  | Optional          | Maximum memory                                           | null    |
| helm_configs.env                 | map     | Optional          | Environment variables                                    | {}      |
| helm_configs.configmaps_list     | list    | Optional          | List of config maps                                      | []      |
| helm_configs.secrets_list        | list    | Optional          | List of secrets                                          | []      |
| helm_configs.volume_mounts       | object  | Optional          | Volume mounts configuration                              | {}      |
| helm_configs.volume_mounts.configmaps | map  | Optional         | Config maps volume mounts                                | {}      |
| helm_configs.volume_mounts.secrets | map    | Optional          | Secrets volume mounts                                    | {}      |

### Services Configuration

| Key                                 | Type       | Required/Optional | Description                                                | Default   |
|-------------------------------------|------------|-------------------|------------------------------------------------------------|-----------|
| repo_name                           | string     | Optional          | Repository name                                            | `null`    |
| acr_name                            | string     | Optional          | Azure Container Registry name                             | `null`    |
| acr_resource_group                  | string     | Optional          | Azure resource group for the container registry           | `null`    |
| db_name                             | string     | Optional          | Database name                                              | `null`    |
| redis                               | bool       | Optional          | Enable Redis                                               | `null`    |
| local_redis                         | bool       | Optional          | Enable local Redis                                         | `null`    |
| enable_default_ingress              | bool       | Optional          | Enable default ingress configurations                      | `null`    |
| ingress_list                        | list       | Optional          | List of ingress configurations                             |           |
| custom_secrets                      | list       | Optional          | List of custom secrets                                     |           |
| enable_basic_auth                   | bool       | Optional          | Enable basic authentication                               | `null`    |
| helm_configs                        | object     | Optional          | Helm chart configurations                                  |           |
| helm_configs.image_pull_secrets     | list       | Optional          | List of image pull secrets                                |           |
| helm_configs.replica_count          | number     | Optional          | Number of replicas                                         | `null`    |
| helm_configs.cli_service            | bool       | Optional          | CLI service enable flag                                    | `null`    |
| helm_configs.http_port              | string     | Optional          | HTTP port                                                  | `null`    |
| helm_configs.metrics_port           | string     | Optional          | Metrics port                                               | `null`    |
| helm_configs.ports                  | map        | Optional          | Service ports                                              |           |
| helm_configs.min_cpu                | string     | Optional          | Minimum CPU                                                | `null`    |
| helm_configs.min_memory             | string     | Optional          | Minimum memory                                             | `null`    |
| helm_configs.max_cpu                | string     | Optional          | Maximum CPU                                                | `null`    |
| helm_configs.max_memory             | string     | Optional          | Maximum memory                                             | `null`    |
| helm_configs.min_available          | number     | Optional          | Minimum available replicas                                | `null`    |
| helm_configs.heartbeat_url          | string     | Optional          | Heartbeat URL                                              | `null`    |
| helm_configs.env                    | map        | Optional          | Environment variables                                     |           |
| helm_configs.configmaps_list        | list       | Optional          | List of config maps                                       |           |
| helm_configs.secrets_list           | list       | Optional          | List of secrets                                           |           |
| helm_configs.hpa                    | object     | Optional          | Horizontal Pod Autoscaler (HPA) configuration             |           |
| helm_configs.hpa.enable             | bool       | Optional          | Enable HPA                                                 | `null`    |
| helm_configs.hpa.min_replicas       | number     | Optional          | Minimum replicas for HPA                                  | `null`    |
| helm_configs.hpa.max_replicas       | number     | Optional          | Maximum replicas for HPA                                  | `null`    |
| helm_configs.hpa.cpu_limit          | number     | Optional          | CPU limit for HPA                                         | `null`    |
| helm_configs.hpa.memory_limit       | number     | Optional          | Memory limit for HPA                                      | `null`    |
| helm_configs.readiness_probes       | object     | Optional          | Readiness probe configuration                              |           |
| helm_configs.readiness_probes.enable| bool       | Optional          | Enable readiness probe                                    | `null`    |
| helm_configs.readiness_probes.initial_delay_seconds | number | Optional | Initial delay in seconds for readiness probe              | `null`    |
| helm_configs.readiness_probes.period_seconds       | number | Optional | Period in seconds for readiness probe                     | `null`    |
| helm_configs.readiness_probes.timeout_seconds      | number | Optional | Timeout in seconds for readiness probe                    | `null`    |
| helm_configs.readiness_probes.failure_threshold     | number | Optional | Failure threshold for readiness probe                     | `null`    |
| helm_configs.liveness_probes        | object     | Optional          | Liveness probe configuration                               |           |
| helm_configs.liveness_probes.enable | bool       | Optional          | Enable liveness probe                                     | `null`    |
| helm_configs.liveness_probes.initial_delay_seconds | number | Optional | Initial delay in seconds for liveness probe               | `null`    |
| helm_configs.liveness_probes.period_seconds       | number | Optional | Period in seconds for liveness probe                      | `null`    |
| helm_configs.liveness_probes.timeout_seconds      | number | Optional | Timeout in seconds for liveness probe                     | `null`    |
| helm_configs.liveness_probes.failure_threshold     | number | Optional | Failure threshold for liveness probe                      | `null`    |
| helm_configs.volume_mounts          | object     | Optional          | Volume mounts configuration                               |           |
| helm_configs.volume_mounts.configmaps | map       | Optional          | Config maps volume mounts                                 |           |
| helm_configs.volume_mounts.secrets  | map        | Optional          | Secrets volume mounts                                     |           |

### cassandra_db
| Inputs           | Type   | Required/Optional | <div style="width:400px">Description</div> | Default |
|------------------|--------|-------------------|--------------------------------------------|---------|
| admin_user       | string | Required          | Admin User of the DB                       | `null`  |
| replica_count    | number | Required          | Replica Count of the DB                    | `null`  |
| persistence_size | number | Required          | Persistence size of the DB                 | `null`  |

### sql_db
| Inputs       | Type         | Required/Optional | <div style="width:400px">Description</div>                          | Default                |
|--------------|--------------|-------------------|---------------------------------------------------------------------|------------------------|
| admin_user   | string       | Optional          | Admin user for the sql instance                                     | `"postgresqladmin"`    |
| sku_name     | string       | Optional          | Specifies the SKU Name for this SQL Server                          | `"GP_Standard_D2s_v3"` |
| enable_ssl   | bool         | Optional          | Whether SSL should be enabled or not based on user requirement      | `false`                |
| read_replica | bool         | Optional          | Specifies whether read-replica is required or not                   | `false`                |
| type         | string       | Optional          | The SQL instance type (e.g - MySQL, PostgreSQL)                     | `postgresql`           |


### Redis
| Inputs                    | Type   | Required/Optional | <div style="width:400px">Description</div>                                                                  | Default |
|---------------------------|--------|-------------------|-------------------------------------------------------------------------------------------------------------|---------|
| redis_cache_capacity      | number | Required          | The size of the Redis cache to deploy                                                                       | `null`  |
| sku_name                  | string | Required          | The SKU of Redis to use (eg. Basic, Standard and Premium)                                                   | `null`  |
| redis_cache_family        | string | Required          | The SKU family/pricing group to use. Valid values are C (for Basic/Standard SKU family) and P (for Premium) | `null`  |
| redis_enable_non_ssl_port | bool   | Required          | Enable the non-SSL port (6379) - disabled by default                                                        | `null`  |

### Local Redis Configuration

| Key             | Type    | Required/Optional | Description                                             | Default |
|-----------------|---------|-------------------|---------------------------------------------------------|---------|
| enable          | bool    | Required          | Enable Redis instance                                  | `null`  |
| disk_size       | string  | Optional          | Disk size for Redis instance                           | `null`  |
| storage_class   | string  | Optional          | Storage class for Redis                               | `null`  |
| max_cpu         | string  | Optional          | Maximum CPU for Redis instance                         | `null`  |
| min_cpu         | string  | Optional          | Minimum CPU for Redis instance                         | `null`  |
| max_memory      | string  | Optional          | Maximum memory for Redis instance                      | `null`  |
| min_memory      | string  | Optional          | Minimum memory for Redis instance                      | `null`  |

### Helm Charts Configuration

| Key     | Type      | Required/Optional | Description                                      | Default |
|---------|-----------|-------------------|--------------------------------------------------|---------|
| name    | string    | Optional          | Name of the Helm chart                           | `{}`    |
| chart   | string    | Optional          | Path to the Helm chart                           | `{}`    |
| repo    | string    | Optional          | Repository URL for the Helm chart                | `{}`    |
| version | string    | Optional          | Version of the Helm chart                        | `{}`    |
| values  | string    | Optional          | Values file for Helm chart                       | `{}`    |
| timeout | number    | Optional          | Timeout for the Helm chart installation          | `{}`    |

### Shared Services Configuration

| Key               | Type      | Required/Optional | Description                                          | Default |
|-------------------|-----------|-------------------|------------------------------------------------------|---------|
| type              | string    | Required          | Type of the shared service                          |         |
| bucket            | string    | Required          | Bucket name for the shared service                  |         |
| profile           | string    | Optional          | Profile for the shared service                      | `null`  |
| location          | string    | Optional          | Location of the shared service                      | `null`  |
| resource_group    | string    | Optional          | Resource group for the shared service               | `null`  |
| storage_account   | string    | Optional          | Storage account for the shared service              | `null`  |
| container         | string    | Optional          | Container name for the shared service               | `null`  |
| cluster_prefix    | string    | Optional          | Prefix for the cluster related to the shared service| `null`  |
