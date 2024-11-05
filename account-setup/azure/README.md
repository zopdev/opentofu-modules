# AWS Terraform Module

The `azure` module contains all the resources to setup the complete project.
It also contains the VPC and subnet provisioning configuration.

### Variables
| Inputs              | Type         | Required/Optional | <div style="width:400px">Description</div>                             | Default           |
|---------------------|--------------|-------------------|------------------------------------------------------------------------|-------------------|
| address_space       | list(string) | Optional          | The address space that is used by the virtual network                     | `["10.0.0.0/16"]` |
| resource_group_name | string       | Required          | The Azure Resource Group name in which all resources should be created |     `""`            |
| vnet                | string       | Required          | Name of the virtual network where the AKS will deploy                  |        `""`           |