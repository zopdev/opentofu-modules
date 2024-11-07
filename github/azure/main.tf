data "azurerm_key_vault_secret" "git_pat" {
  name           = "${var.owner}-git-pat"
  key_vault_id   = data.azurerm_key_vault.secrets.id
}

resource "github_repository" "app_repo" {
  for_each    = var.github_repos
  name        = each.value.name
  description = each.value.name
  visibility  = each.value.visibility != null ? each.value.visibility : "private"
  auto_init   = true
}

resource "github_branch" "app_repo_branch" {
  for_each   = { for k, v in var.github_repos : k => v.default_branch if v.default_branch != null }
  repository = github_repository.app_repo[each.key].name
  branch     = each.value
  depends_on = [ github_repository.app_repo ]
}

resource "github_branch_default" "app_default_branch" {
  for_each   = { for k, v in var.github_repos : k => v.default_branch if v.default_branch != null }
  repository = github_repository.app_repo[each.key].name
  branch     = each.value
  depends_on = [ github_branch.app_repo_branch ]
}

provider "github" {
  token = data.azurerm_key_vault_secret.git_pat.value
  owner = var.owner
}

terraform {
  backend "azurerm" {}
}
