# AWS Terraform Module

The `AWS` module contains all the resources to setup the complete project.
It also contains the VPC and subnet provisioning configuration.

### Variables
| Inputs  | Type        | Required/Optional | <div style="width:400px">Description</div> | Default |
|---------|-------------|-------------------|--------------------------------------------|---------|
| subnets | map(object) | Required          | CIDR block for subnets                     | `{}`    |


#### Subnets
| Inputs               | Type         | Required/Optional | <div style="width:400px">Description</div>                        | Default |
|----------------------|--------------|-------------------|-------------------------------------------------------------------|---------|
| availability_zones   | list(string) | Required          | List of availability zones in which the subnets should be created | `null`  |
| db_subnets_cidr      | list(string) | Required          | List of CIDR blocks for database subnets                          | `null`  |
| private_subnets_cidr | list(string) | Required          | List of CIDR blocks for private subnets                           | `null`  |
| public_subnets_cidr  | list(string) | Required          | List of CIDR blocks for public subnets                            | `null`  |
| vpc_cidr             | string       | Required          | The CIDR block for the Virtual Private Cloud (VPC)                | `""`    |

