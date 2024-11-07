# Account-setup
setups all the prerequisites required before infrastructure setup for AWS and GCP.

## aws

### resources
`aws_vpc`
- It is used to define and provision a VPC.

`aws_subnet`
- This resource is typically used in conjunction with the aws_vpc resource to define and provision subnets within a VPC.

`aws_internet_gateway`
- This resource is used to create and manage an internet gateway within your VPC.

`aws_route_table`
- This resource is used to create and manage route tables within your VPC.

`aws_eip`
- This resource is used to create and manage Elastic IP addresses within your AWS infrastructure. It enables you to allocate, associate, and release Elastic IP addresses programmatically.

`aws_nat_gateway`
- This resource is used to create and manage NAT gateways within your VPC.

`aws_route`
- This resource is used to create and manage routes within a route table.

`aws_route_table_association`
- This resource is used to create and manage the association between a subnet and a route table.

`aws_security_group`
- This resource is used to create and manage security groups within your AWS infrastructure.

## gcp

GOOGLE APIS to be enabled to setup the complete project along-with VPC and subnet provisioning configuration.

### google_project_service

`cloudresourcemanager.googleapis.com`
- Creates, reads, and updates metadata for Google Cloud Platform resource containers.

`compute.googleapis.com`
- Creates and runs virtual machines on Google Cloud Platform. 

`container.googleapis.com`
- Builds and manages container-based applications, powered by the open source Kubernetes technology.

`sqladmin.googleapis.com`   
- Cloud SQL provides a REST API for administering your instances programmatically.

`secretmanager.googleapis.com`
- Stores sensitive data such as API keys, passwords, and certificates. Provides convenience while improving security.

`redis.googleapis.com`
- Creates and manages Redis instances on the Google Cloud Platform.

`dns.googleapis.com`
- Google Cloud DNS is a scalable, reliable and managed authoritative Domain Name System (DNS) service.

`servicenetworking.googleapis.com`
- Provides automatic management of network configurations necessary for certain services.

