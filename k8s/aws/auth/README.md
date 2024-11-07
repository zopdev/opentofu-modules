# AUTH

Setups the auth for the IAM users in the AWS.

#### Variables

| Inputs                           | Type         | Required/Optional | Description                                                                                                                                         | Default      |
|----------------------------------|--------------|-------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|--------------|
| app_env                          | string       | Optional          | Application deployment environment.                                                                                                                 | `""`         |
| app_name                         | string       | Optional          | This is the name for the project. This name is also used to namespace all the other resources created by this module.                                | `""`         |
| editors                          | list(string) | Optional          | List of IAM users who get Editor access to the Cluster                                                                                              | `[]`         |
| ecr_configs                      | list(object) | Optional          | List of ECR (Elastic Container Registry) configurations.                                                                                            | `[]`         |
| masters                          | list(string) | Optional          | List of IAM users who get Admin access to the Cluster                                                                                               | `[]`         |
| provider_id                      | string       | Required          | Profile name                                                                                                                                        |              |
| shared_services                  | object       | Optional          | Configuration object for shared services.                                                                                                           |              |
| system_authenticated_admins      | list(string) | Optional          | List of IAM users who get Authentication access to the Cluster and Admin access on any namespace                                                    | `[]`         |
| system_authenticated_editors     | list(string) | Optional          | List of IAM users who get Authentication access to the Cluster and Editor access on any namespace                                                   | `[]`         |
| system_authenticated_viewers     | list(string) | Optional          | List of IAM users who get Authentication access to the Cluster and Viewer access on any namespace                                                   | `[]`         |
| viewers                          | list(string) | Optional          | List of IAM users who get Viewer access to the Cluster                                                                                              | `[]`         |

##### shared_services object fields:

| Field               | Type     | Required/Optional | Description            | Default |
|---------------------|----------|-------------------|------------------------|---------|
| type                | string   | Required          | Type of shared service |         |
| bucket              | string   | Required          | S3 bucket name         |         |
| profile             | string   | Optional          | Profile name           |         |
| location            | string   | Optional          | Location               |         |
| resource_group      | string   | Optional          | Resource group name    |         |
| storage_account     | string   | Optional          | Storage account name   |         |
| container           | string   | Optional          | Container name         |         |
| cluster_prefix      | string   | Optional          | Cluster prefix         |         |

##### ecr_configs list(object) fields:

| Field               | Type     | Required/Optional | Description      | Default |
|---------------------|----------|-------------------|------------------|---------|
| name                | string   | Required          | ECR name         |         |
| region              | string   | Required          | AWS region       |         |
| account_id          | string   | Required          | AWS account ID   |         |
