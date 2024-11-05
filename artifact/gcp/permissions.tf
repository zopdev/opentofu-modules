locals {
  user_repos = flatten([
    for service_key, service_config in var.registry_permissions : [
      for user_id in service_config.users : "${coalesce(service_key)}:${user_id}"
    ]
  ])
}

resource "google_artifact_registry_repository_iam_member" "user_artifact_member" {
  for_each  = toset(local.user_repos)
  provider      = google
  location   = var.app_region
  repository = split(":",each.value)[0]
  role       = "roles/artifactregistry.writer"
  member     = "user:${split(":",each.value)[1]}"
}