# GCP Terraform Module

The `GCP` module contains all the GOOGLE APIS to be enabled to setup the complete project.
It also contains the VPC and subnet provisioning configuration.

### Variables
| Inputs      | Type        | Required/Optional | <div style="width:400px">Description</div>     | Default |
|-------------|-------------|-------------------|------------------------------------------------|---------|
| app_region  | string      | Required          | Region for creating the network configurations | `""`    |
| provider_id | string      | Required          | Project ID                                     | `""`    |
| vpc_config  | map(object) | Required          | VPC configuration in Project                   | `{}`    |


#### vpc_config
| Inputs               | Type         | Required/Optional | <div style="width:400px">Description</div> | Default |
|----------------------|--------------|-------------------|--------------------------------------------|---------|
| private_subnets_cidr | list(string) | Required          | List of CIDR blocks for private subnets    | `null`  |