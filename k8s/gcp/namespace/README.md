# GCP Namespace Terraform module

The `namespace` module contains all resources that are required for creating a namespace resources in GKE cluster. 
This module is the root module for the other modules such as `db`, `redis` etc.

## Ingress List

The external IP allocated to the Ingress Controller serves as the destination for all incoming traffic. To facilitate this, include it within a DNS zone under your control.
</br>
</br>
#### Steps to Add Custom Ingress for Service

Step I - Obtain the External IP Address of the LoadBalancer using the following command
`kubectl get services -n kube-system`
</br>
Step II -  Create a DNS Record: Choose a DNS zone that you have control over, and Generate a DNS Record using the obtained external IP address.
</br>
Step III - Add the DNS name to ingress_list for the service

## Values

| Inputs                     | Type         | Required/Optional | <div style="width:400px">Description</div>                                                          | Default       |
|----------------------------|--------------|-------------------|-----------------------------------------------------------------------------------------------------|---------------|
| accessibility             | object            | Optional           | The list of user access for the account setup.                                                          | `{}`          |
| app_env                    | string            | Optional           | Application deployment environment.                                               | `""`    |
| app_name                   | string            | Required           | This is the name of the cluster. This name is also used to namespace all the other resources created by this module. |         |
| artifact_registry_location | string            | Optional           | Required location of the artifact registry.                                                             | `us-central1` |
| artifact_users             | list(string)      | Optional           | List of users who have access to the artifact repository.            | `[]`    |
| bucket_name                | string            | Required           | Name of the bucket.                                                                                      |               |
| cassandra_db               | object            | Required           | Inputs to provision Cassandra instances.                                                                | `null`        |
| cert_issuer_env            | string            | Optional           | Environment (prod or stage) to be used for LetsEncrypt Certificate Issuer.                             | `stage`       |
| cluster_key               | string            | Optional           | Path for terraform state file of cluster.                                          | `""`    |
| cluster_prefix            | string            | Optional           | Prefix for cluster Terraform state file.                                                                | `""`          |
| common_tags               | map(string)       | Optional           | Additional tags for merging with common tags.                                                           | `{}`          |
| cron_jobs                  | map(object)       | Optional           | Map of cron jobs to be executed within the namespace.                | `{}`    |
| custom_namespace_secrets   | list(string)      | Optional           | List of GCP secrets that were manually created by prefixing cluster name, environment, and namespace.   | `[]`          |
| deploy_env                 | string            | Optional           | Deployment environment.                                                                                  | `null`        |
| ext_rds_sg_cidr_block      | list              | Optional           | List of CIDR blocks which need to be whitelisted on RDS security group (currently applicable for QA).  | `["10.0.0.0/8"]` |
| github_owner               | string            | Optional           | Name of the GitHub organization to create repositories within it.                                        | `""`          |
| helm_charts                | map(object)       | Optional           | Helm chart installation inputs.                                                                         | `{}`          |
| local_redis                | object            | Optional           | Inputs to provision Redis instance within the cluster as a statefulset.| `null`  |
| namespace                  | string            | Optional           | Namespace of the Services to be deployed.                                         | `""`    |
| provider_id                | string            | Optional           | ID of the GCP project.                                                             | `""`    |
| provisioner                | string            | Optional           | Provisioner being used to set up infrastructure.                                                        | `zop-dev`     |
| redis                      | object            | Optional           | Inputs to provision Redis instances in the cloud platform.           | `null`  |
| services                   | map(object)       | Optional           | Map of services to be deployed within the namespace.                              | `{}`    |
| sql_db                     | object            | Optional           | Inputs to provision SQL instance.                                    | `null`  |
| standard_tags              | object            | Optional           | Standard tags for resources.                                                                           | `null`        |
| user_access                | object            | Optional           | List of users who will have access to clusters.                      |  |


### Services - Types

| Key                              | Required/Optional | Type              | Description                                                                                                    | Default |
|----------------------------------|--------------------|-------------------|----------------------------------------------------------------------------------------------------------------|---------|
| repo_name                        | Optional           | string            | Repository name for the service.                                                                             |         |
| gar_name                         | Optional           | string            | Google Artifact Registry name for the service.                                                               |         |
| gar_project                      | Optional           | string            | Google Artifact Registry project ID.                                                                         |         |
| db_name                          | Optional           | string            | Database name associated with the service.                                                                    |         |
| redis                            | Optional           | bool              | Flag to indicate if Redis is enabled for the service.                                                         |         |
| local_redis                      | Optional           | bool              | Flag to indicate if local Redis is enabled for the service.                                                   |         |
| service_account                  | Optional           | string            | Service account associated with the service.                                                                  |         |
| custom_secrets                   | Optional           | list(string)      | List of custom secrets for the service.                                                                       |         |
| ingress_list                     | Optional           | list(string)      | List of ingress configurations for the service.                                                               |         |
| enable_basic_auth                | Optional           | bool              | Flag to enable basic authentication for the service.                                                          |         |
| enable_default_ingress           | Optional           | bool              | Flag to enable default ingress for the service.                                                               |         |
| helm_configs                     | Optional           | object            | Helm configurations for the service.                                                                          |         |
| helm_configs.image_pull_secrets  | Optional           | list(string)      | List of image pull secrets for the Helm configuration.                                                         | `[]`    |
| helm_configs.replica_count       | Optional           | number            | Number of replicas for the Helm configuration.                                                                 |         |
| helm_configs.cli_service         | Optional           | bool              | Flag to indicate if CLI service is enabled for the Helm configuration.                                         |         |
| helm_configs.http_port           | Optional           | string            | HTTP port for the Helm configuration.                                                                         |         |
| helm_configs.metrics_port        | Optional           | string            | Metrics port for the Helm configuration.                                                                      |         |
| helm_configs.min_cpu             | Optional           | string            | Minimum CPU requirement for the Helm configuration.                                                           |         |
| helm_configs.min_memory          | Optional           | string            | Minimum memory requirement for the Helm configuration.                                                         |         |
| helm_configs.max_cpu             | Optional           | string            | Maximum CPU requirement for the Helm configuration.                                                           |         |
| helm_configs.max_memory          | Optional           | string            | Maximum memory requirement for the Helm configuration.                                                         |         |
| helm_configs.min_available       | Optional           | number            | Minimum available replicas for the Helm configuration.                                                         |         |
| helm_configs.heartbeat_url       | Optional           | string            | Heartbeat URL for the Helm configuration.                                                                     |         |
| helm_configs.ports               | Optional           | map(any)          | Ports for the Helm configuration.                                                                            |         |
| helm_configs.env                 | Optional           | map(any)          | Environment variables for the Helm configuration.                                                             |         |
| helm_configs.configmaps_list     | Optional           | list(string)      | List of ConfigMaps for the Helm configuration.                                                                 |         |
| helm_configs.secrets_list        | Optional           | list(string)      | List of secrets for the Helm configuration.                                                                   |         |
| helm_configs.hpa                 | Optional           | object            | Horizontal Pod Autoscaler configurations for the Helm configuration.                                          |         |
| helm_configs.hpa.enable          | Optional           | bool              | Flag to enable HPA for the Helm configuration.                                                                 |         |
| helm_configs.hpa.min_replicas    | Optional           | number            | Minimum replicas for HPA.                                                                                    |         |
| helm_configs.hpa.max_replicas    | Optional           | number            | Maximum replicas for HPA.                                                                                    |         |
| helm_configs.hpa.cpu_limit       | Optional           | number            | CPU limit for HPA.                                                                                           |         |
| helm_configs.hpa.memory_limit    | Optional           | number            | Memory limit for HPA.                                                                                        |         |
| helm_configs.readiness_probes    | Optional           | object            | Readiness probes configurations for the Helm configuration.                                                   |         |
| helm_configs.readiness_probes.enable | Optional       | bool              | Flag to enable readiness probes for the Helm configuration.                                                   |         |
| helm_configs.readiness_probes.initial_delay_seconds | Optional | number | Initial delay seconds for readiness probes.                                                               |         |
| helm_configs.readiness_probes.period_seconds | Optional | number | Period seconds for readiness probes.                                                                        |         |
| helm_configs.readiness_probes.timeout_seconds | Optional | number | Timeout seconds for readiness probes.                                                                       |         |
| helm_configs.readiness_probes.failure_threshold | Optional | number | Failure threshold for readiness probes.                                                                     |         |
| helm_configs.liveness_probes     | Optional           | object            | Liveness probes configurations for the Helm configuration.                                                    |         |
| helm_configs.liveness_probes.enable | Optional       | bool              | Flag to enable liveness probes for the Helm configuration.                                                    |         |
| helm_configs.liveness_probes.initial_delay_seconds | Optional | number | Initial delay seconds for liveness probes.                                                                  |         |
| helm_configs.liveness_probes.period_seconds | Optional | number | Period seconds for liveness probes.                                                                         |         |
| helm_configs.liveness_probes.timeout_seconds | Optional | number | Timeout seconds for liveness probes.                                                                        |         |
| helm_configs.liveness_probes.failure_threshold | Optional | number | Failure threshold for liveness probes.                                                                      |         |
| helm_configs.volume_mounts       | Optional           | object            | Volume mounts configurations for the Helm configuration.                                                      |         |
| helm_configs.volume_mounts.configmaps | Optional    | map(object)       | ConfigMaps volume mounts.                                                                                   |         |
| helm_configs.volume_mounts.configmaps.mount_path | Required | string | Mount path for ConfigMaps volume mounts.                                                                    |         |
| helm_configs.volume_mounts.configmaps.sub_path | Optional | string | Sub path for ConfigMaps volume mounts.                                                                      |         |
| helm_configs.volume_mounts.configmaps.read_only | Optional | bool | Flag to indicate if ConfigMaps volume mounts are read-only.                                                   |         |
| helm_configs.volume_mounts.secrets | Optional       | map(object)       | Secrets volume mounts.                                                                                      |         |
| helm_configs.volume_mounts.secrets.mount_path | Required | string | Mount path for Secrets volume mounts.                                                                       |         |
| helm_configs.volume_mounts.secrets.sub_path | Optional | string | Sub path for Secrets volume mounts.                                                                         |         |
| helm_configs.volume_mounts.secrets.read_only | Optional | bool | Flag to indicate if Secrets volume mounts are read-only.                                                     |         |

### Cron jobs - Types

| Key                              | Type              | Required/Optional | Description                                                                                                    | Default |
|----------------------------------|-------------------|--------------------|----------------------------------------------------------------------------------------------------------------|---------|
| repo_name                        | string            | Optional           | Repository name for the cron job.                                                                            |         |
| gar_name                         | string            | Optional           | Google Artifact Registry name for the cron job.                                                              |         |
| gar_project                      | string            | Optional           | Google Artifact Registry project ID for the cron job.                                                        |         |
| db_name                          | string            | Optional           | Database name associated with the cron job.                                                                  |         |
| redis                            | bool              | Optional           | Flag to indicate if Redis is enabled for the cron job.                                                         |         |
| local_redis                      | bool              | Optional           | Flag to indicate if local Redis is enabled for the cron job.                                                   |         |
| service_account                  | string            | Optional           | Service account associated with the cron job.                                                                |         |
| custom_secrets                   | list(string)      | Optional           | List of custom secrets for the cron job.                                                                       |         |
| ingress_list                     | list(string)      | Optional           | List of ingress configurations for the cron job.                                                             |         |
| enable_basic_auth                | bool              | Optional           | Flag to enable basic authentication for the cron job.                                                          |         |
| enable_default_ingress           | bool              | Optional           | Flag to enable default ingress for the cron job.                                                               |         |
| helm_configs                     | object            | Optional           | Helm configurations for the cron job.                                                                          |         |
| helm_configs.image_pull_secrets  | list(string)      | Optional           | List of image pull secrets for the Helm configuration.                                                         | `[]`    |
| helm_configs.schedule            | string            | Required           | Schedule for the cron job.                                                                                     |         |
| helm_configs.suspend             | bool              | Optional           | Flag to suspend the cron job.                                                                                  |         |
| helm_configs.concurrency_policy  | string            | Optional           | Concurrency policy for the cron job.                                                                          |         |
| helm_configs.http_port           | string            | Optional           | HTTP port for the Helm configuration.                                                                         |         |
| helm_configs.metrics_port        | string            | Optional           | Metrics port for the Helm configuration.                                                                      |         |
| helm_configs.min_cpu             | string            | Optional           | Minimum CPU requirement for the Helm configuration.                                                           |         |
| helm_configs.min_memory          | string            | Optional           | Minimum memory requirement for the Helm configuration.                                                         |         |
| helm_configs.max_cpu             | string            | Optional           | Maximum CPU requirement for the Helm configuration.                                                           |         |
| helm_configs.max_memory          | string            | Optional           | Maximum memory requirement for the Helm configuration.                                                         |         |
| helm_configs.env                 | map(any)          | Optional           | Environment variables for the Helm configuration.                                                             |         |
| helm_configs.configmaps_list     | list(string)      | Optional           | List of ConfigMaps for the Helm configuration.                                                                 |         |
| helm_configs.secrets_list        | list(string)      | Optional           | List of secrets for the Helm configuration.                                                                   |         |
| helm_configs.volume_mounts       | object            | Optional           | Volume mounts configurations for the Helm configuration.                                                       |         |
| helm_configs.volume_mounts.configmaps | map(object) | Optional           | ConfigMaps volume mounts.                                                                                      |         |
| helm_configs.volume_mounts.configmaps.mount_path | string | Required           | Mount path for ConfigMaps volume mounts.                                                                      |         |
| helm_configs.volume_mounts.configmaps.sub_path | string | Optional           | Sub path for ConfigMaps volume mounts.                                                                        |         |
| helm_configs.volume_mounts.configmaps.read_only | bool | Optional           | Flag to indicate if ConfigMaps volume mounts are read-only.                                                     |         |
| helm_configs.volume_mounts.secrets | map(object) | Optional           | Secrets volume mounts.                                                                                       |         |
| helm_configs.volume_mounts.secrets.mount_path | string | Required           | Mount path for Secrets volume mounts.                                                                         |         |
| helm_configs.volume_mounts.secrets.sub_path | string | Optional           | Sub path for Secrets volume mounts.                                                                           |         |
| helm_configs.volume_mounts.secrets.read_only | bool | Optional           | Flag to indicate if Secrets volume mounts are read-only.                                                       |         |

### User Access - Types

| Key          | Type             | Required/Optional | Description                                  | Default |
|--------------|------------------|--------------------|----------------------------------------------|---------|
| admins       | list(string)     | Optional           | List of users who have admin access.        | `[]`    |
| viewers      | list(string)     | Optional           | List of users who have viewer access.       | `[]`    |
| editors      | list(string)     | Optional           | List of users who have editor access.       | `[]`    |

### SQL_DB - Types

| Key                   | Type         | Required/Optional | Description                               | Default |
|-----------------------|--------------|--------------------|-------------------------------------------|---------|
| enable                | bool         | Optional           | Whether to enable the SQL instance.       | `null`  |
| machine_type          | string       | Optional           | Machine type for the SQL instance.        | `null`  |
| disk_size             | number       | Optional           | Size of the disk for the SQL instance.    | `null`  |
| type                  | string       | Optional           | Type of SQL database | `null`  |
| availability_type     | string       | Optional           | Availability type. | `null`  |
| deletion_protection   | bool         | Optional           | Whether to enable deletion protection.    | `null`  |
| read_replica          | bool         | Optional           | Whether to enable read replicas.          | `null`  |
| activation_policy     | string       | Optional           | Activation policy for the SQL instance.   | `null`  |
| db_collation          | string       | Optional           | Collation setting for the database.       | `null`  |
| enable_ssl            | bool         | Optional           | Whether to enable SSL for the SQL instance. | `null`  |
| sql_version           | string       | Optional           | SQL version to use.       | `null`  |

### Redis - Types


| Inputs          | Type       | Required/Optional | <div style="width:400px">Description</div>                                                | Default |
|-----------------|------------|-------------------|---------------------------------------------------------------------------------------------|---------|
| machine_type    | string     | Required          | Type of the machine to use for Redis instances.                                           |         |
| memory_size     | string     | Required          | Size of memory allocated for Redis instances.                                             |         |
| replica_count   | number     | Required          | Number of Redis replicas to create.                                                        |         |
| redis_version   | string     | Optional          | Version of Redis to use.                                                                   | `null`  |

### Local Redis - Types 

| Inputs          | Type       | Required/Optional | <div style="width:400px">Description</div>                                                | Default |
|-----------------|------------|-------------------|---------------------------------------------------------------------------------------------|---------|
| enable          | bool       | Required          | Whether to enable the Redis instance within the cluster.                                  |         |
| disk_size       | string     | Optional          | Size of the disk for the Redis statefulset.                                               | `null`  |
| max_cpu         | string     | Optional          | Maximum CPU resources allocated for the Redis instance.                                   | `null`  |
| max_memory      | string     | Optional          | Maximum memory resources allocated for the Redis instance.                                | `null`  |
| min_cpu         | string     | Optional          | Minimum CPU resources allocated for the Redis instance.                                   | `null`  |
| min_memory      | string     | Optional          | Minimum memory resources allocated for the Redis instance.                                | `null`  |
| storage_class   | string     | Optional          | Storage class for the Redis statefulset.                                                   | `null`  |

### Cassandra DB - Types 

| Inputs            | Type   | Required/Optional | <div style="width:400px">Description</div>                                                | Default |
|-------------------|--------|-------------------|---------------------------------------------------------------------------------------------|---------|
| admin_user        | string | Required          | Username for the Cassandra database admin.                                                |         |
| persistence_size  | number | Required          | Size of persistent storage for Cassandra instances.                                        |         |
| replica_count     | number | Required          | Number of Cassandra replicas to create.                                                    |         |

### Helm Chart - Types 
| Inputs    | Type                                                                 | Required/Optional | <div style="width:400px">Description</div>                                    | Default |
|-----------|----------------------------------------------------------------------|-------------------|---------------------------------------------------------------------------------|---------|
| chart     | string                                                               | Optional          | Name of the Helm chart to install.                                              | `null`  |
| name      | string                                                               | Optional          | Name to assign to the Helm release.                                              | `null`  |
| repo      | string                                                               | Optional          | Repository URL where the Helm chart is located.                                 | `null`  |
| timeout   | number                                                               | Optional          | Timeout duration for Helm chart installation in seconds.                         | `null`  |
| values    | string                                                               | Optional          | Values file for customizing the Helm chart configuration.                        | `null`  |
| version   | string                                                               | Optional          | Version of the Helm chart to install.                                            | `null`  |


### custom_env
| Inputs | Type   | Required/Optional | <div style="width:400px">Description</div> | Default |
|--------|--------|-------------------|--------------------------------------------|---------|
| key    | string | Required          | Name of env variable                       | `null`  |
| value  | string | Required          | Value of env variable                      | `null`  |