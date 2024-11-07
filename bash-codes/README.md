# Bash-Codes
This module contains the bash codes for creation of hosted zone, remote state and secrets in AWS and GCP.

## aws

`hosted_zones`
- The script leverages the AWS CLI and Route 53 commands to create a hosted zone for the specified domain name, retrieve the associated nameservers, and display the results.

`remote_state`
- The script leverages the AWS CLI to create an S3 bucket with the specified name and region using the provided AWS profile.

`secrets`
- The script leverages the AWS CLI to create a secret in AWS Secrets Manager.


## gcp

`hosted_zones`
- The script leverages the gcloud command-line tool to create a new DNS zone in Google Cloud DNS and retrieve the associated name servers.

`remote_state`
- It creates a new bucket in Google Cloud Storage with the specified project ID, bucket name, and location.

`secrets`
- It creates a new secret in Google Cloud Secrets Manager and add a version with the provided secret data.

`service_account`
- It creates a service account, generate a key for the service account, and grant the service account the specified roles in the project identified by PROJECT_ID.