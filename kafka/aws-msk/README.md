# AWS_MSK Module

The `aws-msk` module contains all the resources required to setup aws-msk.

## Variables

| Inputs                | Type         | Required/Optional | <div style="width:420px">Description</div>                                                                                     | Default          |
|-----------------------|--------------|-------------------|--------------------------------------------------------------------------------------------------------------------------------|------------------|
| app_region            | string       | Required          | Cloud region to deploy to (e.g. us-east-1)                                                                                     |                  |
| common_tags           | Map(string)  | Required          | Additional tags for merging with common tags                                                                                   | `{}`             |
| kafka_admin_user      | string       | Required          | Admin user for msk cluster                                                                                                     |                  |
| kafka_broker_instance | string       | Optional          | Specify the instance type to use for the kafka brokers                                                                         | `kafka.t3.small` |
| kafka_broker_nodes    | number       | Required          | The desired total number of broker nodes in the kafka cluster. It must be a multiple of the number of specified client subnets | `0`              |
| kafka_cluster_name    | string       | Required          | EKS cluster name                                                                                                               |                  |
| kafka_size            | number       | Optional          | The size in GiB of the EBS volume for the data drive on each broker node                                                       | `10`             |
| kafka_subnets         | list(string) | Required          | A list of subnets to connect to in client VPC                                                                                  |                  |
| kafka_topics          | list(object) | Required          | Kafka Topics to be created                                                                                                     | `[]`             |

#### kafka_topics
| Inputs             | Type   | Required/Optional | <div style="width:400px">Description</div>         |
|--------------------|--------|-------------------|----------------------------------------------------|
| name               | string | Required          | The name of the kafka topic                        | 
| partitions         | number | Required          | The number of partitions the topic is spread over  |         
| replication_factor | number | Required          | The number of copies of data over multiple brokers |  