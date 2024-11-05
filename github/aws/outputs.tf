output "repository_url" {
  value = {
    for k, v in github_repository.app_repo : k => v.html_url
  }
}

output "team_admin_members" {
  value = {
    for k in distinct([for k in values(local.github_repo_admin_access) : k.team]) : k => [
      for v in values(local.github_repo_admin_access) :
      v.user if v.team == k
    ]
  }
}

output "team_editor_members" {
  value = {
    for k in distinct([for k in values(local.github_repo_editor_access) : k.team]) : k => [
      for v in values(local.github_repo_editor_access) :
      v.user if v.team == k
    ]
  }
}

output "team_viewer_members" {
  value = {
    for k in distinct([for k in values(local.github_repo_viewer_access) : k.team]) : k => [
      for v in values(local.github_repo_viewer_access) :
      v.user if v.team == k
    ]
  }
}