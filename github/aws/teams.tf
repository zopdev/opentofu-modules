data "github_organization" "organization" {
    name = var.owner
}

locals {
  org_members = data.github_organization.organization.members
  github_repo_admin_access = merge([
    for team in keys(var.github_teams) : tomap({
      for user in var.github_teams[team].admins : "${team}-${user}" => {
            user = user
            team = team
    }
  })
  ]...)

  github_repo_editor_access = merge([
    for team in keys(var.github_teams) : tomap({
      for user in var.github_teams[team].editors : "${team}-${user}" => {
        user = user
        team = team
      }
    })
  ]...)

  github_repo_viewer_access = merge([
    for team in keys(var.github_teams) : tomap({
      for user in var.github_teams[team].viewers : "${team}-${user}" => {
        user = user
        team = team
      }
    })
  ]...)

}
resource "github_team" "admin_team" {
  for_each    = var.github_teams
  name        = "${each.key}_admin"
}

resource "github_team" "editor_team" {
  for_each    = var.github_teams
  name        = "${each.key}_editor"
}

resource "github_team" "viewer_team" {
  for_each    = var.github_teams
  name        = "${each.key}_viewer"
}

resource "github_team_membership" "admin_team" {
  for_each  = local.github_repo_admin_access
  team_id   = github_team.admin_team[each.value.team].id
  username  = each.value.user
  role      = "member"
}

resource "github_team_membership" "editor_team" {
  for_each  = local.github_repo_editor_access
  team_id   = github_team.editor_team[each.value.team].id
  username  = each.value.user
  role      = "member"
}

resource "github_team_membership" "viewer_team" {
  for_each  = local.github_repo_viewer_access
  team_id   = github_team.viewer_team[each.value.team].id
  username  = each.value.user
  role      = "member"
}

resource "github_team_repository" "admin_team" {
    for_each   =  var.github_repos
    team_id    =  github_team.admin_team[each.value.team_name].id
    repository =  github_repository.app_repo[each.key].name
    permission = "admin"
}

resource "github_team_repository" "editor_team" {
    for_each   =  var.github_repos
    team_id    =  github_team.editor_team[each.value.team_name].id
    repository =  github_repository.app_repo[each.key].name
    permission = "push"
}

resource "github_team_repository" "viewer_team" {
    for_each   =  var.github_repos
    team_id    =  github_team.viewer_team[each.value.team_name].id
    repository =  github_repository.app_repo[each.key].name
    permission = "pull"
}