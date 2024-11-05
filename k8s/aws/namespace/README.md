# AWS Namespace Terraform module

The `namespace` module contains all resources that are required for creating a namespace resources in GKE cluster. 
This module is the root module for the other modules such as db, redis etc

## Values

| Inputs                   | Type         | Required/Optional | <div style="width:400px">Description</div>                                                          | Default |
|--------------------------|--------------|-------------------|-----------------------------------------------------------------------------------------------------|---------|
| app_env                  | string       | Required          | Application deployment environment                                                                  | `""`    |
| app_name                 | string       | Required          | This is the name for the project. This name is also used to namespace all the other resources created by this module.                                                                                 |    |
| app_region               | string       | Required          | Cloud region to deploy resources                                                                    |     |
| cassandra_db             | object       | Optional          | Inputs to provision Cassandra instances                                                             | `null`  |
| common_tags              | map(string)  | Optional          | Additional tags for merging with common tags for resources                                | `{}`    |
| custom_namespace_secrets | list(string) | Optional          | List of aws secrets that were manually created by prefixing cluster name and environment  | `[]`    |
| dynamo_db                | map(object)  | Optional          | Map for dynaomo_db inputs                                                           | `{}`    |
| domain_name              | string       | Required          | Cloud DNS host name for the service                                                                 | `""`    |
| editors                  | list(string) | Optional          | List of users who require editor access to the namespace                                            | `[]`    |
| ext_rds_sg_cidr_block    | list         | Optional          | List of cidr blocks which need to be whitelisted on rds sg                                          | `[]`    |
| ingress_custom_domain    | map(any)     | Optional          | Map for k8 ingress for custom domain, for example configuration, [click here](./vars.tf)            | `{}`    |
| kafka                    | map(object)  | Optional          | Map of inputs for Kafka configuration                                                               | `{}`    |
| namespace                | string       | Required          | Namespace of the Services to be deployed                                                            | `""`    |
| provider_id              | string       | Required          | AWS account profile name                                                                            | `""`    |
| public_ingress           | string       | Optional          | Whether ingress is public or not                                                                    | `false` |
| rds_local_access         | bool         | Optional          | whether RDS needs to be allowed to access from local                                                | `false` |
| redis                    | object       | Optional          | Inputs to provision Redis instances                                                                 | `null`  |
| services                 | map(object)  | Required          | Map of services to be deployed within the namespace                                                 | `{}`    |
| sql_db                   | object       | Optional          | Inputs to provision SQL instance, for more information [click here](./vars.tf)                      | `null`  |
| viewers                  | list(string) | Required          | List of users who require viewer access to the namespace                                            | `[]`    |


#### cassandra_db
| Inputs           | Type   | Required/Optional | <div style="width:400px">Description</div> | Default |
|------------------|--------|-------------------|--------------------------------------------|---------|
| admin_user       | string | Required          | Admin User of the DB                       | `null`  |
| replica_count    | number | Required          | Replica Count of the DB                    | `null`  |
| persistence_size | number | Required          | Persistence size of the DB                 | `null`  |

#### dynamo_db
| Inputs           | Type   | Required/Optional | <div style="width:400px">Description</div> | Default |
|------------------|--------|-------------------|--------------------------------------------|---------|
| hash_key       | string | Required          | Key used for Dynamo DB                     | `null`  |
| range_key    | number | Required          | Replica Count of the DB                    | `null`  |
| hash_key_type | number | Required          | Persistence size of the DB                 | `null`  |


#### services
| Inputs         | Type         | Required/Optional | <div style="width:400px">Description</div>                                                                    | Default |
|----------------|--------------|-------------------|---------------------------------------------------------------------------------------------------------------|---------|
| custom_env     | list(object) | Optional          | List of envs that user want to add in configmap                                                               | `null`  |
| custom_secrets | list(string) | Optional          | List of AWS secrets that were manually created by prefixing cluster name, environment, namespace and service  | `null`  |
| db_name        | string       | Optional          | Name of the Database being used by the service, required to setup configs & secrets in kubernetes environment | `null`  |
| repo_name      | string       | Optional          | Github Repository name where the deploy keys to be setup                                                      | `null`  |


#### custom_env
| Inputs | Type   | Required/Optional | <div style="width:400px">Description</div> | Default |
|--------|--------|-------------------|--------------------------------------------|---------|
| key    | string | Required          | Name of env variable                       | `null`  |
| value  | string | Required          | Value of env variable                      | `null`  |