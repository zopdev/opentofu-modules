# OCI Terraform Module

The `OCI` module contains all the resources to set up the complete project.  
It also includes the Virtual Cloud Network (VCN) and subnet provisioning configuration.

## Variables

| Inputs       | Type        | Required/Optional | Description                                             | Default |
|-------------|------------|-------------------|---------------------------------------------------------|---------|
| subnets     | map(object) | Required          | CIDR block for VCNs and subnets                        | `{}`    |
| provider_id | string      | Required          | Compartment ID where the resources will be created     | `""`    |

### Subnets

| Inputs               | Type         | Required/Optional | Description                                            | Default |
|----------------------|-------------|-------------------|--------------------------------------------------------|---------|
| vpc_cidr            | string      | Required          | The CIDR block for the Virtual Cloud Network (VCN)   | `""`    |
| public_subnets_cidr  | list(string) | Required          | List of CIDR blocks for public subnets               | `null`  |
| private_subnets_cidr | list(string) | Required          | List of CIDR blocks for private subnets              | `null`  |
| db_subnets_cidr      | list(string) | Required          | List of CIDR blocks for database subnets             | `null`  |

