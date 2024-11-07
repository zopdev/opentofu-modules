# Artifacts
Setups the artifacts required in GCP.

#### Variables
| Inputs              | Type         | Required/Optional | <div style="width:400px">Description</div>                                   | Default      |
|---------------------|--------------|-------------------|------------------------------------------------------------------------------|--------------|
| app_region          | string       | Required          | Location where the resources to be created                                   | `"eastus"`   |
| resource_group_name | string       | Required          | The Azure Resource Group name in which all resources should be created       | `""`         |
| services            | list(string) | Required          | List of services to create artifact container registry repositories in Azure | `[]`         |
| sku                 | string       | Optional          | The SKU name of the container registry (e.g - Basic, Standard and Premium)   | `"Standard"` |

