locals {
  github_plan = data.github_organization.organization.plan

  github_secrets = [
    for key,value in var.github_repos :  {
      name = value.name
      secrets = local.github_plan == "free" ? concat(value.secrets,var.organization_secrets) : value.secrets
    }
  ]

  repository_secrets_map = merge([
    for key,value in local.github_secrets : {
    for secret in value.secrets : "${value.name}-${secret}" =>  {
      repo   = value.name
      secret = secret
    }
  }
  ]...)
}

data "azurerm_key_vault" "secrets" {
  name                = "${var.owner}-key-vault"
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "repo_secrets" {
  for_each      = local.repository_secrets_map
  name          = each.value["secret"]
  key_vault_id  = data.azurerm_key_vault.secrets.id
}

resource "github_actions_secret" "repo_secrets" {
  for_each  = local.repository_secrets_map
  repository = each.value["repo"]
  secret_name = each.value["secret"]
  plaintext_value = data.azurerm_key_vault_secret.repo_secrets[each.key].value
  depends_on = [github_repository.app_repo]
}

data "azurerm_key_vault_secret" "organization_secrets" {
  for_each      = local.github_plan != "free" ? toset(var.organization_secrets) : []
  name          = each.value
  key_vault_id  = data.azurerm_key_vault.secrets.id
}

resource "github_actions_organization_secret" "organization_secrets" {
  for_each = toset(local.github_plan != "free" ? var.organization_secrets : [])
  secret_name     = each.value
  visibility      = "private"
  plaintext_value = data.azurerm_key_vault_secret.organization_secrets[each.value].value
  depends_on = [github_repository.app_repo]
}