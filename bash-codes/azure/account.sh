#!/bin/bash

# Function to check if a user has a specific role
check_role() {
    local user_principal_name="$1"
    local role_template_id="$2"
    local token="$3"

    # Set the URL for Microsoft Graph API
    local graph_url="https://graph.microsoft.com/v1.0"

    # Query the members of the specified role
    local members_response=$(curl -s -H "Authorization: Bearer $token" "$graph_url/directoryRoles(roleTemplateId='$role_template_id')/members")

    # Extract the userPrincipalName from the response
    local members=$(echo "$members_response" | grep -o '"userPrincipalName":\s*"[^\"]*"' | sed -n 's/"userPrincipalName":\s*"\([^\"]*\)"/\1/p')
    # Check if the user is found in the role
    for member in $members; do
        if [ "$member" == "$user_principal_name" ]; then
            return 0
        fi
    done

    return 1
}

# Function to check if the user has the required permissions
check_permissions() {
    local subscription_id="$1"
    local required_roles=("Owner" "User Access Administrator")

     # Check if subscription_id is empty
      if [ -z "$subscription_id" ]; then
          echo "Subscription ID is empty or null. Cannot create service principal."
          return 1
      fi


    # Get the current user's object ID
    local user_object_id=$(az ad signed-in-user show --query id --output tsv)

    if [ -z "$user_object_id" ]; then
        echo "Failed to get the current user's object ID."
        exit 1
    fi

    # Get the role assignments for the user
    local role_assignments=$(az role assignment list --assignee "$user_object_id" --subscription "$subscription_id")

    # Check if the user has any of the required roles
    for role in "${required_roles[@]}"; do
        if echo "$role_assignments" | grep -q "\"roleDefinitionName\": \"$role\""; then
            return 0
        fi
    done

    return 1
}

# Function to create service principal and output credentials
create_service_principal() {
    local subscription_id="$1"

    # Check if subscription_id is empty
    if [ -z "$subscription_id" ]; then
        echo "Subscription ID is empty or null. Cannot create service principal."
        return 1
    fi

    # Create service principal with Owner role
    local sp_info=$(az ad sp create-for-rbac --role="Owner" --scopes="/subscriptions/$subscription_id")

    # Extract necessary information from the output
    local client_id=$(echo "$sp_info" | grep -o '"appId": "[^"]*' | awk -F'"' '{print $4}')
    local client_secret=$(echo "$sp_info" | grep -o '"password": "[^"]*' | awk -F'"' '{print $4}')
    local tenant_id=$(echo "$sp_info" | grep -o '"tenant": "[^"]*' | awk -F'"' '{print $4}')
    local display_name=$(echo "$sp_info" | grep -o '"displayName": "[^"]*' | awk -F'"' '{print $4}')

    az ad app permission add --id $client_id --api 00000003-0000-0000-c000-000000000000 --api-permissions 741f803b-c850-494e-b5df-cde7c675a1ca=Role 19dbc75e-c2e2-444c-a770-ec69d8559fc7=Role 62a82d76-70ea-41e2-9197-370581804d09=Role 1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9=Role

    sleep 10


    echo $client_id adding admin consent
    az ad app permission admin-consent --id $client_id

    # Output the required information in the desired format
    echo ""
    echo ""
    echo "{"
    echo "  \"subscriptionId\": \"$subscription_id\","
    echo "  \"tenantId\"   : \"$tenant_id\","
    echo "  \"appId\"      : \"$client_id\","
    echo "  \"password\"    : \"$client_secret\""
    echo "  \"display_name\" :\"$display_name\""
    echo "}"

    echo "{" > azure_credentials.json
    echo "  \"subscriptionId\": \"$subscription_id\"," >> azure_credentials.json
    echo "  \"tenantId\"   : \"$tenant_id\"," >> azure_credentials.json
    echo "  \"appId\"      : \"$client_id\"," >> azure_credentials.json
    echo "  \"password\"    : \"$client_secret\"" >> azure_credentials.json
    echo "}" >> azure_credentials.json
}

echo "Logging into Azure..."
login_output=$(az login)

# Extract the subscription ID from the login output using grep and awk
subscription_id="$(echo "$login_output" | grep -o '"id": "[^"]*' | awk -F'"' '{print $4}')"

# Set the subscription
az account set --subscription="$subscription_id"

token=$(az account get-access-token --resource https://graph.microsoft.com --query accessToken --output tsv)

if [ -z "$token" ]; then
    echo "Failed to get the access token. Please check your Azure CLI login."
    exit 1
fi

# Define the role template IDs to check
role_template_id1="62e90394-69f5-4237-9190-012177145e10"
role_template_id2="e8611ab8-c189-46e8-94e1-60213ab1f814"

# Get the user principal name
signed_in_user_upn=$(az ad signed-in-user show --query userPrincipalName --output tsv)

if [ -z "$signed_in_user_upn" ]; then
    echo "Failed to retrieve signed-in user's UPN. Please check your Azure CLI login."
    exit 1
fi

echo "Signed-in user's UPN: $signed_in_user_upn"


# Check if the user has the specified roles
echo "Checking if the user has the roles with template IDs $role_template_id1 , $role_template_id2 or Owner role..."
if check_role "$signed_in_user_upn" "$role_template_id1" "$token" ||(check_role "$signed_in_user_upn" "$role_template_id2" "$token" && check_permissions "$subscription_id"); then
    echo "User has the required roles."
    echo "Creating service principal..."
    create_service_principal "$subscription_id"
else
    echo "User does not have all the required roles.(User Should Have Global Administrator Role or combination of Privileged Role Administrator and Owner)"
fi
