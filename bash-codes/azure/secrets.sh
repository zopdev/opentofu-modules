#! /bin/bash

# Set the name of the key vault you want to create
echo Enter the key vault name:
read KEY_VAULT_NAME

# Set the name of the resource group
echo Enter the resource group name:
read RESOURCE_GROUP_NAME

# Set the location where your key vault exist
echo Enter the location:
read LOCATION

# Set the name of the key vault you want to create
echo Enter the secret name:
read SECRET_NAME

# Set the name of the key vault you want to create
echo Enter the secret value:
read SECRET_VALUE

az keyvault create --name $KEY_VAULT_NAME --resource-group $RESOURCE_GROUP_NAME --location $LOCATION

az keyvault secret set --vault-name $KEY_VAULT_NAME --name $SECRET_NAME --value $SECRET_VALUE
