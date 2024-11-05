# AZURE MYSQL Terraform module

The `azure-postgres` module contains all resources that is required for creating an Postgresql instance.

## Variables

| Inputs                 | Type         | Required/Optional | <div style="width:400px">Description</div>                     | Default              |
|------------------------|--------------|-------------------|----------------------------------------------------------------|----------------------|
| administrator_login    | string       | Optional          | The admin username for mysql database                          | `psqladmin`          |
| administrator_password | string       | Required          | The admin password for mysql database                          | `""`                 |
| backup_retention_days  | number       | Optional          | Backup retention days for the server                           | `7`                  |
| charset                | string       | Optional          | Specific character set encoding                                | `utf8`               |
| cluster_name           | string       | Required          | Name of the cluster to which MySQL instance is attached with   |                      |
| collation              | string       | Optional          | This is the collation type                                     | `en_US.utf8`         |
| databases              | list(string) | Required          | Specifies the name of the MySQL Database                       | `[]`                 |
| enable_ssl             | bool         | Optional          | Whether SSL should be enabled or not based on user requirement | `false`              |
| key_vault_id           | string       | Required          | Id of the azure key vault                                      |                      |
| location               | string       | Required          | Azure location for SQL Server                                  | `""`                 |
| namespace              | string       | Required          | Namespace to which MySQL instance is attached with             |                      |
| postgres_server_name   | string       | Required          | The name of the sql server                                     | `""`                 |
| postgres_version       | string       | Optional          | Version of the mysql database                                  | `13`                 |
| read_replica           | bool         | Optional          | To enable read replica for source mysql server                 | `false`              |
| resource_group_name    | string       | Required          | Azure resource group name for SQL server"                      | `""`                 |
| sku_name               | string       | Optional          | Indicates the type of virtual machine with vCPUs and memory    | `GP_Standard_D2s_v3` |
| storage_mb             | number       | Optional          | The amount of storage for mysql database in MB                 | `32768`              |
| tags                   | map(any)     | Required          | Tags for aws resources                                         |                      |
| zone                   | number       | Optional          | zone for resources                                             | `2`                  |