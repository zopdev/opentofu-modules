locals {
  env = var.deploy_env != null ? var.deploy_env : var.app_env

  github_vars = tomap({
    for k,v in var.services : k => {
      app_name     = k
      account_id   = try(v.account_id, "")
      cluster_name = local.cluster_name
      ecr_repo     = try(v.ecr_repo, "")
      namespace    = var.namespace
      region       = try(v.region, "")
      repo_name    = try(v.repo_name, "")
    } if var.services[k].repo_name != null && var.github_owner != ""
  })

  env_map = tomap({
    for k,v in local.github_vars : "${k}-${v.repo_name}" => [
      "${k}_${local.env}_account_id:${v.account_id}:${v.repo_name}",
      "${k}_${local.env}_app_name:${k}:${v.repo_name}",
      "${k}_${local.env}_cluster_name:${v.cluster_name}:${v.repo_name}",
      "${k}_${local.env}_ecr_repo:${v.ecr_repo}:${v.repo_name}",
      "${k}_${local.env}_namespace:${v.namespace}:${v.repo_name}",
      "${k}_${local.env}_region:${v.region}:${v.repo_name}"
    ] if var.services[k].repo_name != null && var.github_owner != ""
  })

  flattened_env_map = merge([
    for k, v in local.env_map : {
      for key, value in v : "${k}-${key}" => value
    }
  ]...)
}

data "aws_secretsmanager_secret" "git_pat" {
  count = var.github_owner != "" ? 1 : 0
  name  = "${var.github_owner}-git-pat"
}

data "aws_secretsmanager_secret_version" "git_pat" {
  count     = var.github_owner != "" ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.git_pat[0].id
}

resource "github_actions_secret" "git_pat" {
  for_each         = {for key, value in var.services : key => value if var.services[key].repo_name != null }
  repository       = var.services[each.key].repo_name
  secret_name      = "${replace(each.key,"-", "_")}_${local.env}_PAT"
  plaintext_value  = data.aws_secretsmanager_secret_version.git_pat[0].secret_string
}

resource "github_actions_secret" "access_key_id" {
  for_each         = {for key, value in var.services : key => value if var.services[key].repo_name != null }
  repository       = var.services[each.key].repo_name

  secret_name      = "${replace(each.key,"-", "_")}_${local.env}_ACCESS_KEY_ID"
  plaintext_value  = aws_secretsmanager_secret_version.access_key_id_version[each.key].secret_string
}

resource "github_actions_secret" "access_secret" {
  for_each         = {for key, value in var.services : key => value if var.services[key].repo_name != null }
  repository       = var.services[each.key].repo_name

  secret_name      = "${replace(each.key,"-", "_")}_${local.env}_ACCESS_SECRET"
  plaintext_value  = aws_secretsmanager_secret_version.secret_access_key_version[each.key].secret_string
}

resource "github_actions_variable" "action_variable" {
  for_each      = local.flattened_env_map
  repository    = split(":", each.value)[2]
  variable_name = replace(split(":", each.value)[0], "-", "_")
  value         = split(":", each.value)[1]
}

provider "github" {
  token =  var.github_owner != "" ? data.aws_secretsmanager_secret_version.git_pat[0].secret_string : ""
  owner = var.github_owner
}