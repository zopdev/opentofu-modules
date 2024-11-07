# Kops-Kube

#### Variables

| Inputs              | Type         | Required/Optional | <div style="width:400px">Description</div>                                                   | Default |
|---------------------|--------------|-------------------|------------------------------------------------------------------------------------------------|---------|
| app_region          | string       | Required          | App region of the cluster                                                                     |         |
| cluster_name        | string       | Required          | Name of the cluster on which kops-kube should be deployed                                      |         |
| host                | string       | Required          | Domain to be used for kops-kube                                                                 |         |
| resource_group_name | string       | Required          | Resource group where the resources exists                                                      |         |
| shared_services   | object       | Required          | The configuration object containing details for shared services setup.                        |         |

#### shared_services

| Inputs              | Type         | Required/Optional | <div style="width:400px">Description</div>                                                   | Default |
|---------------------|--------------|-------------------|------------------------------------------------------------------------------------------------|---------|
| bucket              | string       | Required          | The name of the storage bucket for shared services.                                             |         |
| cluster_prefix      | string       | Optional          | Prefix to be used for clustering purposes in shared services.                                 |         |
| container           | string       | Optional          | Container name within the storage bucket.                                                       |         |
| location            | string       | Optional          | Geographic location for the shared services resources.                                          |         |
| profile             | string       | Optional          | Profile name or identifier for accessing shared services.                                       |         |
| resource_group      | string       | Optional          | Resource group name for organizing shared services resources.                                  |         |
| storage_account     | string       | Optional          | Storage account name where the shared services data is stored.                                  |         |
| type                | string       | Required          | The type of shared service or storage (e.g., blob, file, etc.).                                 |         |
