resource "google_project_service" "enable_artifact_registry" {
  service = "artifactregistry.googleapis.com"
  provider = google
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "gcr_repo" {
  for_each = toset(var.registries)

  provider      = google
  location      = var.app_region
  repository_id = each.value
  description   = "${each.value} docker repository"
  format        = "DOCKER"

  docker_config {
    immutable_tags = var.immutable_image_tags
  }

  depends_on = [google_project_service.enable_artifact_registry]
}

terraform {
  backend "gcs" {}
}
