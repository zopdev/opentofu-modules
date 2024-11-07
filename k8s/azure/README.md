#### Before starting with the Project, you must create a storage account to use Azure Storage as a backend.

#### Run the following commands or configuration to create an Azure storage account and container:


###### LOCATION= <LOCATION>
###### RESOURCE_GROUP_NAME= <RESOURCE_GROUP_NAME>
###### STORAGE_ACCOUNT_NAME= <STORAGE_ACCOUNT_NAME>
###### CONTAINER_NAME= <CONTAINER_NAME>

### Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

### Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

### Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

#### Run the following commands to get the storage access key and store it as an environment variable:
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
export ARM_ACCESS_KEY=$ACCOUNT_KEY

#### Create a Terraform configuration with a backend configuration block.

###### terraform {
###### backend "azurerm" {
######    resource_group_name      = <RESOURCE_GROUP_NAME>
######    storage_account_name     = <STORAGE_ACCOUNT_NAME>
######    container_name           = <CONTAINER_NAME>
######    key                      = <BLOB_NAME>
######    }
###### }