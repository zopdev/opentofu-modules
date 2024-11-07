#!/bin/bash

set -e

#Gets List of projects accessed by user
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
  service_account_roles=$(gcloud projects get-iam-policy "$selected_project" \
    --flatten="bindings[].members" \
    --format="table(bindings.role)" \
    --filter="bindings.members:serviceAccount:${current_account}")

  output=$(MissingRoles "$service_account_roles")
else
  user_roles=$(gcloud projects get-iam-policy "$selected_project" \
    --flatten="bindings[].members" \
    --format="table(bindings.role)" \
    --filter="bindings.members:user:${current_account}")

  output=$(MissingRoles "$user_roles")
fi

if [[ "$output" != "" ]]; then
  echo "Please add the following roles: $output"
  exit 1
fi

DEFAULT_SERVICE_ACCOUNT_NAME="zopdev-$(date +'%Y%m%d')"

echo "Enter the Service Account Name (Press enter to get default service account name $DEFAULT_SERVICE_ACCOUNT_NAME): "
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
  echo "Service account already exist with the name $SERVICE_ACCOUNT_NAME. Do you want to create service account key for it(y/n) : "
  read option
  if [[ "$option" != "y" ]]; then
     exit 1
  fi
fi

LOG_FILE=zopdev-serviceaccount-$(date +'%Y%m%d%H%M%S').log

if OUTPUT=$(gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME --display-name $DISPLAY_NAME --description "Service account for zop.dev" --project $selected_project 2>&1); then
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

  # Grant the service account the required role
  for role in "${ROLE[@]}"
     do
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

