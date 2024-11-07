# Kops-Kube

#### Variables

| Inputs            | Type         | Required/Optional | <div style="width:400px">Description</div>                                                   | Default |
|-------------------|--------------|-------------------|------------------------------------------------------------------------------------------------|---------|
| app_region        | string       | Required          | App region of the cluster                                                                       |         |
| cluster_name      | string       | Required          | Name of the cluster on which kops-kube should be deployed                                      |         |
| host              | string       | Required          | Domain to be used for kops-kube                                                                 |         |
| provider_id       | string       | Required          | ID of the GCP project                                                                          |         |
| shared_services   | object       | Required          | The configuration object containing details for shared services setup.                        |         |

#### shared_services

| Inputs            | Type         | Required/Optional | <div style="width:400px">Description</div>                                                   | Default |
|-------------------|--------------|-------------------|------------------------------------------------------------------------------------------------|---------|
| bucket            | string       | Required          | The name of the storage bucket.                                                                 |         |
| cluster_prefix    | string       | Optional          | Prefix to be used for clusters.                                                                 |         |
| container         | string       | Optional          | The name of the container within the storage bucket.                                            |         |
| location          | string       | Optional          | The geographical location of the storage account.                                               |         |
| profile           | string       | Optional          | The profile to be used for authentication or configuration.                                      |         |
| resource_group    | string       | Optional          | The resource group in which resources are managed.                                               |         |
| storage_account   | string       | Optional          | The name of the storage account.                                                                  |         |
| type              | string       | Required          | The type of shared service being configured.                                                     |         |
