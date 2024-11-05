# zop-helm

#### Variables

| Inputs                         | Type         | Required/Optional | <div style="width:400px">Description</div>                                                        | Default |
|--------------------------------|--------------|-------------------|-----------------------------------------------------------------------------------------------------|---------|
| app_secrets                    | list(string) | Required          | List of secrets from where the env should be injected onto container                             |         |
| cli_service                    | bool         | Required          | If provided service is of type ClI or not                                                           |         |
| configmaps_list                | list(string) | Required          | List of configmaps from where the env should be injected onto container                           |         |
| db_ssl_enabled                 | bool         | Required          | Boolean value whether to mount the DB SSL secrets on the container or not                          |         |
| enable_liveness_probe          | bool         | Required          | To enable liveness probe on the container or not                                                   |         |
| enable_readiness_probe         | bool         | Required          | To enable readiness probe on the container or not                                                  |         |
| env                            | map(any)     | Required          | Environment variables to be defined for a container                                                |         |
| heartbeat_url                  | string       | Required          | Health Check path for the kubelet to consider the container to be alive and healthy               |         |
| hpa_cpu_limit                  | string       | Required          | Scaling target to be set by HPA for CPU utilisation                                                |         |
| hpa_enable                     | bool         | Required          | Enable HPA for the deployment                                                                     |         |
| hpa_max_replicas               | number       | Required          | Maximum number of replicas to be controlled                                                        |         |
| hpa_min_replicas               | number       | Required          | Minimum number of replicas to be controlled                                                        |         |
| hpa_memory_limit               | string       | Required          | Scaling target to be set by HPA for memory utilisation                                            |         |
| image                          | string       | Required          | Image to be used for deployment                                                                   |         |
| image_pull_secrets             | list(string) | Required          | Secrets to pull the images from the container registries                                           |         |
| liveness_failure_threshold     | string       | Required          | The number of time kubelet should run the probe to consider container is not ready/healthy/live   |         |
| liveness_initial_delay_seconds | number       | Required          | Initial delay seconds that kubelet should wait before performing the first liveness probe          |         |
| liveness_period_seconds        | number       | Required          | How often (in seconds) that kubelet should perform liveness probe                                 |         |
| liveness_timeout_seconds       | number       | Required          | Number of seconds after which the liveness probe times out                                        |         |
| max_cpu                        | string       | Required          | CPU limit for a container, values should be defined only in `millicpu` measure                     |         |
| max_memory                     | string       | Required          | Memory limit for a container, values should be defined only in `Mi` measure                        |         |
| min_available                  | number       | Required          | PDBs to specify a minimum availability for a particular type of pod for high availability          |         |
| min_cpu                        | string       | Required          | CPU request for a container, values should be defined only in `millicpu` measure                   |         |
| min_memory                     | string       | Required          | Memory request for a container, values should be defined only in `Mi` measure                      |         |
| metrics_port                   | number       | Required          | Port number to be used for metrics                                                                |         |
| name                           | string       | Required          | Name of the service                                                                               |         |
| namespace                      | string       | Required          | Namespace where the resources should be created                                                    |         |
| ports                          | map(any)     | Required          | Map of ports that should be configured on container                                               |         |
| replica_count                  | number       | Required          | Count of Replicas should be created for a deployment                                               |         |
| readiness_failure_threshold    | string       | Required          | The number of time kubelet should run the probe to consider container is not ready/healthy/live   |         |
| readiness_initial_delay_seconds| number       | Required          | Initial delay seconds that kubelet should wait before performing the first readiness probe         |         |
| readiness_period_seconds       | number       | Required          | How often (in seconds) that kubelet should perform readiness probe                                |         |
| readiness_timeout_seconds      | number       | Required          | Number of seconds after which the readiness probe times out                                       |         |
| secrets_list                   | list(string) | Required          | List of secrets from where the env should be injected onto container                             |         |
| suspend                        | bool         | Required          | Either to suspend execution of Jobs for a CronJob                                                   |         |
| volume_mount_configmaps        | map(object)  | Required          | List of configmaps that should be mounted onto the container                                      |         |
| volume_mount_secrets           | map(object)  | Required          | List of secrets that should be mounted onto the container                                        |         |

#### volume_mount_configmaps
| Inputs              | Type                  | Required/Optional | <div style="width:400px">Description</div>                                           | Default |
|---------------------|-----------------------|-------------------|----------------------------------------------------------------------------------------|---------|
| mount_path          | string                | Required          | Path where the ConfigMap is mounted in the volume.                                    |         |
| read_only           | bool                  | Optional          | Specifies whether the ConfigMap should be mounted as read-only.                       |  |
| sub_path            | string                | Optional          | Subpath within the volume where the ConfigMap should be mounted.                      |         |

#### volume_mount_secrets
| Inputs              | Type                  | Required/Optional | <div style="width:400px">Description</div>                                           | Default |
|---------------------|-----------------------|-------------------|----------------------------------------------------------------------------------------|---------|
| mount_path          | string                | Required          | Path where the Secret is mounted in the volume.                                       |         |
| read_only           | bool                  | Optional          | Specifies whether the Secret should be mounted as read-only.                          | `false` |
| sub_path            | string                | Optional          | Subpath within the volume where the Secret should be mounted.                         |         |