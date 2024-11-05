data "terraform_remote_state" "infra_output" {
  backend = "azurerm"
  config = {
    resource_group_name   = var.resource_group
    storage_account_name  = var.storage_account
    container_name        = var.container
    key                   = "${var.bucket_prefix}/terraform.tfstate"
  }
}