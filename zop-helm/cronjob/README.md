# zop-helm

#### Variables
| Inputs                   | Type         | Required/Optional | <div style="width:400px">Description</div>                                                        | Default |
|--------------------------|--------------|-------------------|-----------------------------------------------------------------------------------------------------|---------|
| app_secrets              | list(string) | Required          | List of secrets from where the env should be injected onto container                              |         |
| concurrency_policy       | string       | Required          | Concurrency Policy of a CronJob. Accepted values `Forbid`, `Replace` and `Allow`                   |         |
| configmaps_list          | list(string) | Required          | List of configmaps from where the env should be injected onto container                            |         |
| db_ssl_enabled           | bool         | Required          | Boolean value whether to mount the DB SSL secrets on the container or not                          |         |
| env                      | map(any)     | Required          | Environment variables to be defined for a container                                               |         |
| image                    | string       | Required          | Image to be used for deployment                                                                   |         |
| image_pull_secrets       | list(string) | Required          | Secrets to pull the images from the container registries                                           |         |
| http_port                | number       | Required          | HTTP Port number to be used                                                                       |         |
| max_cpu                  | string       | Required          | CPU limit for a container, values should be defined only in `millicpu` measure                     |         |
| max_memory               | string       | Required          | Memory limit for a container, values should be defined only in `Mi` measure                        |         |
| min_cpu                  | string       | Required          | CPU request for a container, values should be defined only in `millicpu` measure                   |         |
| min_memory               | string       | Required          | Memory request for a container, values should be defined only in `Mi` measure                      |         |
| metrics_port             | number       | Required          | Port number to be used for metrics                                                                |         |
| name                     | string       | Required          | Name of the service                                                                               |         |
| namespace                | string       | Required          | Namespace where the resources should be created                                                    |         |
| schedule                 | string       | Required          | The scheduled time for a cron                                                                      |         |
| secrets_list             | list(string) | Required          | List of secrets from where the env should be injected onto container                              |         |
| suspend                  | bool         | Required          | Either to suspend execution of Jobs for a CronJob                                                   |         |
| volume_mount_configmaps  | map(object) | Required          | List of configmaps that should be mounted onto the container                                      |         |
| volume_mount_secrets     | map(object) | Required          | List of secrets that should be mounted onto the container                                        |         |

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
| read_only           | bool                  | Optional          | Specifies whether the Secret should be mounted as read-only.                          |  |
| sub_path            | string                | Optional          | Subpath within the volume where the Secret should be mounted.                         |         |