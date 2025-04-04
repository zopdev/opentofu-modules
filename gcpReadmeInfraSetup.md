# GCP Infrastructure Setup Documentation

This document outlines the steps required to set up a GCP account and deploy artifacts using Terragrunt. It includes prerequisites, infrastructure provisioning, and sample Terragrunt configurations.

## Table of Contents

1. [Goal](#goal)
2. [Prerequisites](#prerequisites)
3. [Account Setup](#account-setup)
4. [Artifact Setup](#artifact-setup)
5. [Cluster Setup](#cluster-setup)
5. [Service Account Creation Script](#service-account-creation-script)
6. [Sample Terragrunt Configurations](#sample-terragrunt-configurations)

## Goal

The primary goal is to set up a GCP infrastructure in a structured manner using OpenTofu modules and Terragrunt.

## Prerequisites

Before proceeding, ensure you have the following:

- **OpenTofu**: Not Required if Terraform is installed - Version >= 1.0.0 (or Terraform if OpenTofu is not available)
- **Terragrunt**: Not Required if OpenTofu is installed - Installed and configured
- **GCP CLI**: Configured with appropriate permissions
- **Git**: For version control and repository access
- **Service Account Credentials**: Ensure you have the necessary service account credentials in JSON format.

## Setup GCP Project

1. **Create a GCP Project**:
   - Set up a new GCP project with the appropriate user groups and permissions.

2. **Configure Service Account**:
   - Ensure that the service account has the necessary roles and permissions to manage resources in the project.

   The following script can be used to create a service account in GCP and generate its credentials. This script checks for necessary permissions, allows the user to select a project, and creates a service account with predefined roles.

```bash
#!/bin/bash

set -e

# Gets List of projects accessed by user
auth_list_output=$(gcloud auth list 2>&1)

if echo "$auth_list_output" | grep -q "No credentialed accounts"; then
  echo "Not Logged In. Please run the 'gcloud auth login' command"
  exit 1
fi

projects_list=$(gcloud projects list --format="value(projectId)")

if [ -z "$projects_list" ]; then
  echo "No projects are available. Please Login with correct email id"
  exit 1
fi

echo "Projects:"
i=1
while read -r project; do
  echo "$i $project"
  ((i++))
done <<< "$projects_list"

echo Enter the number of the project to set as default:
read project_number

if [[ ! "$project_number" =~ ^[1-9][0-9]*$ || "$project_number" -ge "$i" ]]; then
  echo "Invalid input. Please enter a valid project number."
  exit 1
fi

selected_project=$(echo "$projects_list" | sed -n "${project_number}p")
gcloud config set project "$selected_project"

echo "Default project set to: $selected_project"

current_account=$(gcloud config get-value account)

MissingRoles(){
  roles=$1
  svc_count=0
  svc_key_count=0
  iam_count=0
  if echo "$roles" | grep -q "roles/owner"; then
      return
  fi
  svc_acc_roles=("roles/iam.serviceAccountAdmin" "roles/iam.serviceAccountCreator" "roles/editor" "roles/firebase.managementServiceAgent" "roles/firebasemods.serviceAgent" "roles/earthengine.appsPublisher")
  svc_acc_key_roles=("roles/iam.serviceAccountKeyAdmin" "roles/editor")
  iam_policy_roles=("roles/resourcemanager.projectIamAdmin" "roles/iam.securityAdmin" "roles/privilegedaccessmanager.projectServiceAgent" "roles/resourcemanager.organizationAdmin" "roles/krmapihosting.anthosApiEndpointServiceAgent" "roles/gkehub.crossProjectServiceAgent" "roles/resourcemanager.folderAdmin" "roles/firebase.managementServiceAgent" "roles/appengineflex.serviceAgent")
  for role in "${svc_acc_roles[@]}"; do
    if grep -qF "$role" <<< "$roles"; then
      ((svc_count++))
    fi
  done
  for role in "${svc_acc_key_roles[@]}"; do
    if grep -qF "$role" <<< "$roles"; then
      ((svc_key_count++))
    fi
  done
  for role in "${iam_policy_roles[@]}"; do
    if grep -qF "$role" <<< "$roles"; then
      ((iam_count++))
    fi
  done
  if [ "$svc_count" -eq 0 ]; then
    missing_role+="roles/iam.serviceAccountAdmin  "
  fi
  if [ "$svc_key_count" -eq 0 ]; then
    missing_role+="roles/iam.serviceAccountKeyAdmin  "
  fi
  if [ "$iam_count" -eq 0 ]; then
     missing_role+="roles/resourcemanager.projectIamAdmin"
  fi
  echo "$missing_role"
}

if [[ "$current_account" == *@*.iam.gserviceaccount.com ]]; then
  service_account_roles=$(gcloud projects get-iam-policy "$selected_project" --flatten="bindings[].members" --format="table(bindings.role)" --filter="bindings.members:serviceAccount:${current_account}")

  output=$(MissingRoles "$service_account_roles")
else
  user_roles=$(gcloud projects get-iam-policy "$selected_project" --flatten="bindings[].members" --format="table(bindings.role)" --filter="bindings.members:user:${current_account}")

  output=$(MissingRoles "$user_roles")
fi

if [[ "$output" != "" ]]; then
  echo "Please add the following roles: $output"
  exit 1
fi

DEFAULT_SERVICE_ACCOUNT_NAME="zop-$(date +'%Y%m%d')"

echo "Enter the Service Account Name (Enter between 6 to 30 characters) (Press enter to get default service account name $DEFAULT_SERVICE_ACCOUNT_NAME): "
read SERVICE_ACCOUNT
SERVICE_ACCOUNT_NAME=${SERVICE_ACCOUNT// /}

if [ -z "$SERVICE_ACCOUNT_NAME" ]; then
  SERVICE_ACCOUNT_NAME=$DEFAULT_SERVICE_ACCOUNT_NAME
fi

DISPLAY_NAME=$SERVICE_ACCOUNT_NAME

echo "Creating service account...."

ROLE=(
  "roles/editor"
  "roles/container.admin"
  "roles/resourcemanager.projectIamAdmin"
  "roles/iam.roleAdmin"
  "roles/secretmanager.admin"
  "roles/servicenetworking.networksAdmin"
  "roles/storage.admin"
  "roles/dns.admin"
  "roles/artifactregistry.admin"
)

SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$selected_project.iam.gserviceaccount.com"
if gcloud iam service-accounts describe "$SERVICE_ACCOUNT_EMAIL" --project="$selected_project" &> /dev/null; then
  echo "Service account already exists with the name $SERVICE_ACCOUNT_NAME. Do you want to create a service account key for it (y/n): "
  read option
  if [[ "$option" != "y" ]]; then
     exit 1
  fi
fi

LOG_FILE=zscloud-serviceaccount-$(date +'%Y%m%d%H%M%S').log

if OUTPUT=$(gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME --display-name $DISPLAY_NAME --description "Service account for ZS Cloud" --project $selected_project 2>&1); then
    echo "$OUTPUT" >> "$LOG_FILE"
else
    echo "$OUTPUT"
    exit 1
fi

echo "Generating service account key.."
# Create a key for the service account
if OUTPUT=$(gcloud iam service-accounts keys create ${SERVICE_ACCOUNT_NAME}.json --iam-account $SERVICE_ACCOUNT_NAME@$selected_project.iam.gserviceaccount.com --project $selected_project 2>&1); then
    echo "$OUTPUT" >> "$LOG_FILE"
else
    echo "$OUTPUT"
    exit 1
fi

# Grant the service account the required roles
for role in "${ROLE[@]}"; do
  if OUTPUT=$(gcloud projects add-iam-policy-binding $selected_project --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@$selected_project.iam.gserviceaccount.com" --role $role 2>&1); then
      echo "$OUTPUT" >> "$LOG_FILE"
  else
      echo "$OUTPUT"
      exit 1
  fi
done

echo "Please check $LOG_FILE file to see all logs"
echo "${SERVICE_ACCOUNT_NAME}.json"
cat ${SERVICE_ACCOUNT_NAME}.json
```

## Account Setup
The `GCP` module contains all the GOOGLE APIS to be enabled to setup the complete project.
It also contains the VPC and subnet provisioning configuration.

## Artifact Setup
Setups the artifact registry required in GCP.

## Cluster Setup 
The `gke` module contains all resources that are required for creating a GCP GKE cluster, node pools, domain configuration,
prometheus/grafana setup etc. This module is the root module of all the other modules such as `db`, `redis`, `observability` etc.

## Namespace and Services
The `namespace` module contains all resources that are required for creating a namespace resources in GKE cluster.
This module is the root module for the other modules such as `db`, `redis` etc.

## Sample Terragrunt Configurations

### PreRequisites 
Have Directory Stucture like this
```
📂 root
├── 📄 gcp_sources.hcl                           # defining module sources
├── 📂 credentials                               # stores service-account credentials file
│   ├── 📄 accounts.hcl                          # service account credentials for gcp
│   ├── 📄 shared-services.json                  # service account credentials for gcp project which has bucket and domain can be same as accounts.hcl
│   └── 📄 gcp_sources.hcl                       # gcp sources configuration
├── 📂 account-setup
│   └── 📄 terragrunt.hcl
├── 📂 artifact
│   └── 📄 terragrunt.hcl
├── 📂 cluster
│   └── 📄 terragrunt.hcl
└── 📂 namespace
   └── 📄 terragrunt.hcl
```

`sample gcp_sources.hcl file`

```
locals {
  terraform_cluster = "<<path_to_opentofu_repo>>//k8s/gcp/gke"
  terraform_namespace = "<<path_to_opentofu_repo>>//k8s/gcp/namespace"
  terraform_account = "<<path_to_opentofu_repo>>//account-setup/gcp"
  terraform_artifact = "<<path_to_opentofu_repo>>//artifact/gcp"
  terraform_domain = "<<path_to_opentofu_repo>>//hosted-zones/gcp"
  terraform_kops_kube = "<<path_to_opentofu_repo>>//kops-kube/gcp"
  terraform_redis = "<<path_to_opentofu_repo>>//redis/gcp-redis"
  terraform_nat = "<<path_to_opentofu_repo>>//k8s/gcp/nat"
  zopsystem = "<<path_to_opentofu_repo>>//zop-system/gcp"
}
```

### 1. Sample Terragrunt Configuration for Account Setup [Module Docs](https://github.com/zopdev/opentofu-modules/tree/main/account-setup/gcp)

```terragrunt.hcl
# account_setup/terragrunt.hcl
locals {
  sources       = read_terragrunt_config(find_in_parent_folders("gcp_sources.hcl"))
  account       = read_terragrunt_config("${dirname(get_terragrunt_dir())}/accounts.hcl")
  version       = local.account.locals.z_infra_version
  project_id    = "your-project-id"  # Replace with your actual project ID
  creds         = "${dirname(get_terragrunt_dir())}/credentials/account.json"
  shared_service_creds = "${dirname(get_terragrunt_dir())}/credentials/shared-services.json"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
  credentials = "${local.creds}"
  project     = "${local.project_id}"
}
provider "google" {
  alias       = "shared-services"
  credentials = "${local.shared_service_creds}"
  project     = "${local.account.locals.shared_provider_id}"
}
provider "google-beta" {
  credentials = "${local.creds}"
  project     = "${local.project_id}"
}
EOF
}

remote_state {
  backend = "gcs"
  config = {
    bucket      = "your-bucket-name"  # Replace with your actual bucket name
    prefix      = "${local.project_id}/terraform.tfstate"
    credentials = "${local.shared_service_creds}"
  }
}

terraform {
  source = "${local.sources.locals.terraform_account}?ref=${local.version}"
}

inputs = {
  provider_id = local.project_id
  app_region  = "us-central1"  # Example region
  vpc_config  = {
    vpc_cidr = "10.0.0.0/16"  # Example VPC CIDR
    subnets = [
      {
        name = "subnet-1"
        cidr = "10.0.1.0/24"
        region = "us-central1"
      },
      {
        name = "subnet-2"
        cidr = "10.0.2.0/24"
        region = "us-central1"
      }
    ]
  }
}
```

**Explanation of Each Section:**

- **locals**: This block defines local variables used throughout the configuration. It includes paths to source files, project IDs, and credentials.

- **generate "provider"**: This block generates a `provider.tf` file that configures the Google Cloud provider with the necessary credentials and project settings.

- **remote_state**: This block configures the remote state backend to use Google Cloud Storage (GCS) for storing Terraform state files. It specifies the bucket and prefix for the state files.

- **terraform**: This block specifies the source of the Terraform module to be used, pointing to the appropriate module in the repository.

- **inputs**: This block defines the input variables for the Terraform module. It includes the project ID, application region, and VPC configuration with subnets.

### 2. Sample Terragrunt Configuration for Artifact Setup [Module Docs]https://github.com/zopdev/opentofu-modules/tree/main/artifact/gcp)

```hcl
# artifact_setup/terragrunt.hcl
locals {
  sources       = read_terragrunt_config(find_in_parent_folders("gcp_sources.hcl"))
  account       = read_terragrunt_config("${dirname(get_terragrunt_dir())}/accounts.hcl")
  version       = local.account.locals.z_infra_version
  project_id    = "your-project-id"  # Replace with your actual project ID
  creds         = "${dirname(get_terragrunt_dir())}/credentials/account.json"
  shared_service_creds = "${dirname(get_terragrunt_dir())}/credentials/shared-services.json"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
  credentials = "${local.creds}"
  project     = "${local.project_id}"
}
provider "google" {
  alias       = "shared-services"
  credentials = "${local.shared_service_creds}"
  project     = "${local.project_id}"
}
provider "google-beta" {
  credentials = "${local.creds}"
  project     = "${local.project_id}"
}
EOF
}

remote_state {
  backend = "gcs"
  config = {
    bucket      = "your-bucket-name"  # Replace with your actual bucket name
    prefix      = "${local.project_id}/artifact/terraform.tfstate"
    credentials = "${local.shared_service_creds}"
  }
}

terraform {
  source = "${local.sources.locals.terraform_artifact}?ref=${local.version}"
}

inputs = {
  app_region = "us-central1"  # Example region
  registries = ["kops-dev", "zop-dev"]  # Example registry names
}
```

**Explanation of Each Section:**

- **locals**: Similar to the account setup, this block defines local variables for the artifact setup.

- **generate "provider"**: This block generates a `provider.tf` file for the artifact setup, configuring the Google Cloud provider.

- **remote_state**: Configures the remote state backend for the artifact setup, specifying the bucket and prefix for the state files.

- **terraform**: Specifies the source of the Terraform module for the artifact setup.

- **inputs**: Defines the input variables for the artifact module, including the application region and a list of registries.


## Sample Terragrunt Configuration for Cluster Setup  [Module Docs]https://github.com/zopdev/opentofu-modules/tree/main/k8s/gcp/gke)

```hcl
# cluster/terragrunt.hcl
locals {
  sources       = read_terragrunt_config(find_in_parent_folders("gcp_sources.hcl"))
  account       = read_terragrunt_config("${dirname(get_terragrunt_dir())}/accounts.hcl")
  version       = local.account.locals.z_infra_version
  provider_id   = "your-project-id"  # Replace with your actual project ID
  creds         = "${dirname(get_terragrunt_dir())}/credentials/account.json"
  shared_service_creds = "${dirname(get_terragrunt_dir())}/credentials/shared-services.json"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
  credentials = "${local.creds}"
  project     = "${local.provider_id}"
}
provider "google" {
  alias       = "shared-services"
  credentials = "${local.shared_service_creds}"
  project     = "${local.account.locals.shared_provider_id}"
}
provider "google-beta" {
  credentials = "${local.creds}"
  project     = "${local.provider_id}"
}
EOF
}

remote_state {
  backend = "gcs"
  config = {
    bucket      = "${local.account.locals.bucket}"
    prefix      = "${local.input.locals.provider_uuid}/${local.input.locals.cluster_uuid}/terraform.tfstate"
    credentials = "${local.shared_service_creds}"
  }
}

terraform {
  source = "${local.sources.locals.terraform_cluster}?ref=${local.version}"
}

inputs = {
  app_name                   = "my-cluster"  # Name of the cluster
  provider_id                = local.provider_id
  app_region                 = "us-central1"  # Example region
  common_tags                = {
    environment = "production"
    team        = "devops"
  }
  public_ingress             = false
  public_cluster             = false

  user_access = {
    app_admins  = ["admin@example.com"]
    app_viewers = ["viewer@example.com"]
    app_editors = ["editor@example.com"]
  }

  node_config = {
    max_count                  = 5
    min_count                  = 3
    availability_zones         = ["us-central1-a", "us-central1-b"]
    node_type                  = "n1-standard-2"
  }

  accessibility = {
    hosted_zone                = "example.com"
    domain_name                = "my-cluster.example.com"
    cidr_blocks                = ["10.0.0.0/24"]
  }

  observability_config = {
    prometheus = {
      enable = true
      version = "2.30.0"
    }
  }

  shared_service_provider = local.account.locals.shared_provider_id

  vpc = "my-vpc"
  subnet = "my-vpc-private-subnet"

  standard_tags = {
    provisioner = "zop-dev"
  }

  fluent_bit = {
    enable = "true"
    loki = [
      {
        host      = "loki.example.com"
        tenant_id = "tenant-id"
        labels    = "app=my-cluster"
      }
    ]
  }

  provisioner = "zop-dev"

  cert_issuer_config = {
    env   = "production"
    email = "cert-issuer@example.com"
  }

  cluster_alert_webhooks = [
    {
      type = "teams"
      data = "https://example.com/webhook"
    }
  ]
  
  slack_alerts_configs = [
    {
      channel = "#alerts"
      name    = "Cluster Alerts"
      url     = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
    }
  ]
}
```

## Sample Terragrunt Configuration for Namespace and Services Setup [Module Docs]https://github.com/zopdev/opentofu-modules/tree/main/k8s/gcp/namespace)

```hcl
# namespace/terragrunt.hcl
locals {
  sources = read_terragrunt_config(find_in_parent_folders("gcp_sources.hcl"))
  input         = read_terragrunt_config("inputs.hcl")
  account       = read_terragrunt_config("${dirname(get_terragrunt_dir())}/accounts.hcl")
  version       = local.account.locals.z_infra_version
  provider_id   = local.input.locals.provider_id
  creds         = "${dirname(get_terragrunt_dir())}/credentials/account.json"
  shared_service_creds = "${dirname(get_terragrunt_dir())}/credentials/shared-services.json"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
  credentials = "${local.creds}"
  project     = "${local.provider_id}"
}
provider "google" {
  alias       = "shared-services"
  credentials = "${local.shared_service_creds}"
  project     = "${local.account.locals.shared_provider_id}"
}
provider "google" {
  alias       = "artifact-registry"
  credentials = "${local.creds}"
  project     = "${local.provider_id}"
}
provider "google-beta" {
  credentials = "${local.creds}"
  project     = "${local.provider_id}"
}
EOF
}

remote_state {
  backend = "gcs"
  config = {
    bucket      = "${local.account.locals.bucket}"
    prefix      = "${local.input.locals.provider_uuid}/${local.input.locals.cluster_uuid}/${local.input.locals.namespace_uuid}/terraform.tfstate"
    credentials = "${local.shared_service_creds}"
  }
}

generate "services_tfvars" {
  path      = "services.auto.tfvars"
  if_exists = "overwrite"
  contents  = <<EOF
services = ${jsonencode(local.input.locals.services)}
EOF
}

terraform {
  source = "${local.sources.locals.terraform_namespace}?ref=${local.version}"
}

inputs = {
  namespace                 = local.input.locals.namespace
  app_name                  = local.input.locals.app_name
  app_region                = local.input.locals.app_region
  provider_id               = local.provider_id
  cron_jobs                 = local.input.locals.cron_jobs
  bucket_name               = local.account.locals.bucket

  custom_namespace_secrets   = try(local.input.locals.custom_namespace_secrets, [])
  sql_db                     = local.input.locals.sql_db
  sql_list                   = local.input.locals.sql_list
  local_redis                = local.input.locals.local_redis
  incluster_sql              = local.input.locals.incluster_sql
  pub_sub                    = local.input.locals.pub_sub

  artifact_registry_location  = try(local.input.locals.artifact_registry_location, local.input.locals.app_region, "us-central1")
  accessibility = {
    hosted_zone                = local.account.locals.hosted_zone
    domain_name                = "${local.input.locals.cluster_uuid}.${local.account.locals.domain}"
  }
  user_access = {
    editors       = local.input.locals.editors
    viewers       = local.input.locals.viewers
    admins        = local.input.locals.admins
  }

  vpc = local.input.locals.vpc
  subnet = "${local.input.locals.vpc}-private-subnet"

  standard_tags = {
    provisioner = "zop-dev"
  }

  cluster_prefix = "${local.input.locals.provider_uuid}/${local.input.locals.cluster_uuid}"

  provisioner = "zop-dev"

  cert_issuer_config = {
    env   = local.account.locals.issuer_env
    email = local.input.locals.issuer_email
  }

  helm_charts = local.input.locals.helm_charts
}
```
## Conclusion

This documentation serves as a guide for setting up a GCP account and deploying artifacts using Terragrunt. Ensure all prerequisites are met and follow the outlined steps for a successful setup. For any issues or questions, please reach out to the DevOps team.