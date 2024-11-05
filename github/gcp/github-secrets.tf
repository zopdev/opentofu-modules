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

data "google_secret_manager_secret_version" "repo_secrets" {
  provider = google
  for_each = local.repository_secrets_map
  secret  = each.value["secret"]
}

resource "github_actions_secret" "repo_secrets" {
  for_each  = local.repository_secrets_map
  repository = each.value["repo"]
  secret_name = each.value["secret"]
  plaintext_value = data.google_secret_manager_secret_version.repo_secrets[each.key].secret_data
  depends_on = [github_repository.app_repo]
}

data "google_secret_manager_secret_version" "organization_secrets" {
  provider = google
  for_each = local.github_plan != "free" ? toset(var.organization_secrets) : []
  secret = each.value
}

resource "github_actions_organization_secret" "organization_secrets" {
  for_each = toset(local.github_plan != "free" ? var.organization_secrets : [])
  secret_name     = each.value
  visibility      = "private"
  plaintext_value =  data.google_secret_manager_secret_version.organization_secrets[each.value].secret_data
  depends_on = [github_repository.app_repo]
}