#!/bin/bash

# Set the name of the resource group that has the storage account
echo Enter the resource group name:
read RESOURCE_GROUP_NAME

# Set the name of the storage account you want to create
echo Enter the storage account name:
read STORAGE_ACCOUNT_NAME

# Set the name of the storage container you want to create
echo Enter the blob container name:
read CONTAINER_NAME

# Set the location for the storage account
echo Enter the location:
read LOCATION

# Create a resource group
az group create --name $RESOURCE_GROUP_NAME --location "$LOCATION"

# Create a storage account
az storage account create \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --location "$LOCATION" \
    --sku Standard_LRS

# Get the storage account key
accountKey=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" --output tsv)

# Create a container in the storage account
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $accountKey
