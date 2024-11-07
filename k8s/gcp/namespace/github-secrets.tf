locals {

  gar_project_list = tomap({
    for k,v in var.services : k => var.services[k].gar_project != null ? var.services[k].gar_project : google_artifact_registry_repository_iam_member.artifact_member[k].project
    if var.services[k].repo_name != null && var.github_owner != ""
  })

  env = var.deploy_env != null ? var.deploy_env : var.app_env

  env_map = tomap({
    for k,v in var.services : "${k}-${v.repo_name}" => {
      app_name        = "${k}_${local.env}_app_name:${k}:${v.repo_name}"
      cluster_name    = "${k}_${local.env}_cluster_name:${local.cluster_name}:${v.repo_name}"
      namespace       = "${k}_${local.env}_namespace:${var.namespace}:${v.repo_name}"
      cluster_project = "${k}_${local.env}_cluster_project:${var.provider_id}:${v.repo_name}"
      gar_project     = "${k}_${local.env}_gar_project:${local.gar_project_list[k]}:${v.repo_name}"
      gar_registry    = "${k}_${local.env}_gar_registry:${coalesce(v.gar_name, k)}:${v.repo_name}"
    } if var.services[k].repo_name != null && var.github_owner != ""
  })

  flattened_env_map = merge([
    for k, v in local.env_map : {
      for key, value in v : "${k}-${key}" => value
    }
  ]...)
}

resource "github_actions_secret" "deploy_key" {
  for_each         = {for key, value in var.services : key => value if var.services[key].repo_name != null && var.github_owner != ""}
  repository       = var.services[each.key].repo_name

  secret_name      = "${replace(each.key,"-", "_")}_${local.env}_deploy_key"
  plaintext_value  = google_secret_manager_secret_version.namespace_svc_acc[each.key].secret_data
}

resource "github_actions_secret" "git_pat" {
  for_each         = {for key, value in var.services : key => value if var.services[key].repo_name != null && var.github_owner != ""}
  repository       = var.services[each.key].repo_name

  secret_name      = "${replace(each.key,"-", "_")}_${local.env}_pat"
  plaintext_value  = data.google_secret_manager_secret_version.git_pat[0].secret_data
}

data "google_secret_manager_secret_version" "git_pat" {
  count    = var.github_owner != "" ? 1 : 0
  provider = google.shared-services
  secret  = "${var.github_owner}-git-pat"
}

resource "github_actions_variable" "action_variable" {
  for_each      = local.flattened_env_map
  repository    = split(":", each.value)[2]
  variable_name = replace(split(":", each.value)[0], "-", "_")
  value         = split(":", each.value)[1]
}

provider "github" {
  token    = var.github_owner != "" ? data.google_secret_manager_secret_version.git_pat[0].secret_data : ""
  owner    = var.github_owner
}
