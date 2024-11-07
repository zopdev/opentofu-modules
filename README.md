# OpenTofu Modules

This project contains a generic terraform module for creating cloud resources. A separate repository needs to be setup to define the configurations for provisioning the infrastructure. 


## Salient Features
- Minimal Configuration: Default configurations are available for most resources, thereby reducing the effort needed to setup a simple environment having compute(Kubernetes), database(SQL) and cache(Redis) managed resources.
- Integrated Secret Management: Secrets like credentials can be auto-injected into the deployment pipeline, thereby removing the need of human access to secrets.
- Multi-Account Support: Ability to setup environments in separate accounts, for purposes of access control, billing management, etc

## Resources

### Account-setup
- This module sets up prerequisites for Kubernetes Cluster creation such as vpc and subnet provisioning in Cloud Provider.
### Artifact
- This module contains all the resources required artifact setup for AWS and GCP.
### Bash-Codes
- The bash-code module contains all the resources required for creating a hosted-zone, remote-state and secrets for AWS and GCP.
### Cassandra (WIP)
- The cassandra module contains all the resources required for deploying cassandra to kubernetes cluster.
### GitHub
- The GitHub module contains resources which help for the creation of GitHub repos, teams and secrets.
### Kubernetes ( k8s )
- The k8s module is the root module for all the other modules, contains the configuration for Kubernetes clusters and dependent resources.
- It sets up clusters in AWS, GCP and Azure and creates ingress for services.
### Kafka
- The Kafka module will create kafka clusters in AWS and Azure.
### Observability
- The observability module contains configurations to setup Loki, Tempo and Cortex in Cloud Provider.
### Redis
- The redis module contains resources that are required for creating a redis cluster in AWS, Azure and GCP Cloud Providers.
### Sql
- The sql module contains mysql and postgres configuration for AWS,Azure and GCP cloud providers.

## Cloud Infra Provider Support
- AWS
- GCP
- Azure
