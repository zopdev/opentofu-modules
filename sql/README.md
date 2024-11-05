# SQL Terraform Module

The `sql` module contains all the resources required for deploying sql server i.e., mysql, postgres on different cloud providers like in aws, azure, gcp.

## aws-rds
- Amazon RDS is a web service that makes it easier to set up, operate, and scale a relational database in the AWS Cloud.
- This module contains all resources that is required for creating an RDS instance in AWS cloud using given VPC.


#### Resources

`aws_db_subnet_group` 
- It is used to define a group of subnets that can be used by a relational database management system (RDBMS) instance within a virtual private cloud (VPC).

`aws_security_group` 
- It is used to define a virtual firewall that controls inbound and outbound traffic for one or more Amazon Elastic Compute Cloud (EC2) instances, Amazon Relational Database Service (RDS) instances, or other AWS resources that support security groups.

`aws_db_parameter_group` 
- It is used to create and manage parameter groups for Amazon Relational Database Service (RDS) instances.

`aws_db_instance` 
- It is used to create and manage Amazon Relational Database Service (RDS) instances.



## azure-mysql
- Azure Database for MySQL single server is a fully managed database service designed for minimal customization.
- This module contains all resources that is required for creating an MYSQL instance.


#### Resources

`azurerm_mysql_server` 
- This resource in Microsoft Azure is used to create and manage Azure Database for MySQL servers.

`azurerm_mysql_database` 
- It is used to create and manage individual databases within an Azure Database for MySQL server.


## azure-postgres
- Azure Database for postgres is a relational database service based on the open-source Postgres database engine.
- This module contains all resources that is required for creating a postgres instance.

## gcp-sql
- Google Cloud SQL is a fully-managed database service that helps set up and regulate relational databases on the GCP.
- This module contains all resources that is required for creating a sql instance.


#### Resources

`google_compute_firewall` 
- This resource in Google Cloud Platform (GCP) is used to create and manage firewall rules for Google Compute Engine instances.

`google_sql_database_instance` 
- It is used to create and manage Cloud SQL database instances.

`google_sql_database` 
- It s used to create and manage databases within a Cloud SQL instance.


