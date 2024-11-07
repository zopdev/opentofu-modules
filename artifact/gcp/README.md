# Artifacts
Setups the artifacts required in GCP.

#### Variables
| Inputs     | Type         | Required/Optional | <div style="width:400px">Description</div>                       | Default |
|------------|--------------|-------------------|------------------------------------------------------------------|---------|
| app_region | string       | Required          | Cloud region to deploy to (e.g. us-east1)                        | `""`    |
| registries   | list(string) | Required          | List of services to be deployed within the namespace | `[]`    |
| registry_permissions   | map(object) | Required          | List of services to be deployed within the namespace | `{}`    |

#### Registry Permissions
| Inputs     | Type         | Required/Optional | <div style="width:400px">Description</div>                       | Default |
|------------|--------------|-------------------|------------------------------------------------------------------|---------|
| users| list(string)       | Required          | List of User principal names to be added to AAD                       |     |