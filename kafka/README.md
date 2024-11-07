# Kafka Terraform Module
- Kafka is primarily used to build real-time streaming data pipelines and applications that adapt to the data streams.
- This module contains all the resources which are used to setup aws-msk.

## aws-msk
Amazon Managed Streaming for Apache Kafka is an AWS streaming data service that manages Apache Kafka infrastructure and operations.

#### Resources

`aws_security_group`

 It provides details about a specific Security Group.

`aws_cloudwatch_log_group`

  It lets you monitor and troubleshoot your systems and applications using your existing system, application and custom log files. 
  
`aws_msk_cluster`

  It manages a serverless Amazon MSK cluster.

`aws_msk_scram_secret_association`

  This is needed to avoid a centralized management of secrets associated to a MSK cluster.


