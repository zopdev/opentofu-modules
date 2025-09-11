data "terraform_remote_state" "infra_output" {
  backend = "azurerm"
  config = {
    resource_group_name   = var.resource_group
    storage_account_name  = var.storage_account
    container_name        = var.container
    key                   = "${var.bucket_prefix}/terraform.tfstate"
    
    # Service Principal Authentication
    client_id       = var.client_id
    client_secret   = var.client_secret
    tenant_id       = var.tenant_id
    subscription_id = var.subscription_id
  }
}