locals {
  enable_loki   = try(var.observability_config.loki != null ? var.observability_config.loki.enable : false, false)
  enable_tempo  = try(var.observability_config.tempo != null ? var.observability_config.tempo.enable : false, false)
  enable_cortex = try(var.observability_config.cortex != null ? var.observability_config.cortex.enable : false, false)
  enable_mimir  = try(var.observability_config.mimir != null ? var.observability_config.mimir.enable : false,false)
  storage_account = "${replace(local.cluster_name,"-","")}${random_string.storage_account_suffix.result}"
}

resource "random_string" "storage_account_suffix" {
  length    = 6
  numeric   = true
  lower     = true
  upper     = false
  special   = false
}

resource "azurerm_storage_account" "aks_storage_account" {
  count               =  (local.enable_cortex || local.enable_loki || local.enable_tempo || local.enable_mimir) ? 1: 0
  name                = local.storage_account
  resource_group_name = var.resource_group_name
  location            = var.app_region
  account_tier        = "Standard"
  account_replication_type = "RAGRS"
}

resource "azurerm_key_vault_secret" "observability_az_user" {
  count        =  (local.enable_cortex || local.enable_loki || local.enable_tempo || local.enable_mimir) ? 1: 0
  name         = "observability-${local.environment}-azure-user"
  value        = azurerm_storage_account.aks_storage_account[0].primary_access_key
  key_vault_id = azurerm_key_vault.secrets.id
}


module "observability" {
  count       =  (local.enable_cortex || local.enable_loki || local.enable_tempo || local.enable_mimir) ? 1: 0

  source = "../../../observability/azure"

  app_name             = var.app_name
  app_region           = var.app_region
  app_env              = var.app_env
  observability_suffix = var.observability_config.suffix
  resource_group_name  = var.resource_group_name
  storage_account      = local.storage_account
  domain_name          = local.domain_name
  cluster_name         = local.cluster_name
  account_access_key   = azurerm_key_vault_secret.observability_az_user[0].value
  loki                 = var.observability_config.loki
  tempo                = var.observability_config.tempo
  cortex               = var.observability_config.cortex
  mimir                = var.observability_config.mimir

  depends_on           = [helm_release.prometheus,azurerm_storage_account.aks_storage_account]
}
