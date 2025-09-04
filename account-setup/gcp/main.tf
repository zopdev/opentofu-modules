resource "google_project_service" "cloudresourcemanager_project" {
  project     = var.provider_id
  service     = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute_project" {
  project      = var.provider_id
  service      = "compute.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
  depends_on = [google_project_service.cloudresourcemanager_project]
}

resource "google_project_service" "kubernetes_engine_api" {
  project       = var.provider_id
  service       = "container.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
  depends_on = [google_project_service.cloudresourcemanager_project]
}

resource "google_project_service" "cloud_sql" {
  project      = var.provider_id
  service      = "sqladmin.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
  depends_on = [google_project_service.cloudresourcemanager_project]
}

resource "google_project_service" "secret_manager" {
  project      = var.provider_id
  service      = "secretmanager.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
  depends_on = [google_project_service.cloudresourcemanager_project]
}

resource "google_project_service" "redis" {
  project      = var.provider_id
  service      = "redis.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
  depends_on = [google_project_service.cloudresourcemanager_project]
}

resource "google_project_service" "enable_sqladmin_api" {
  service            = "sqladmin.googleapis.com"
  project            = var.provider_id
  disable_on_destroy = false
  depends_on = [google_project_service.cloudresourcemanager_project]
}

resource "google_project_service" "dns" {
  service            = "dns.googleapis.com"
  project            = var.provider_id
  disable_on_destroy = false
  depends_on = [google_project_service.cloudresourcemanager_project]
}

resource "google_project_service" "enable-servicenetworking-api" {
  service = "servicenetworking.googleapis.com"
  project  = var.provider_id
  disable_on_destroy = false
  depends_on = [google_project_service.cloudresourcemanager_project]
}

resource "google_project_service" "certificatemanager_svc" {
  service            = "certificatemanager.googleapis.com"
  project            = var.provider_id
  disable_on_destroy = false
  depends_on = [google_project_service.cloudresourcemanager_project]
}

resource "google_project_service" "serviceusageapi_svc" {
  service            = "serviceusage.googleapis.com"
  project            = var.provider_id
  disable_on_destroy = false
  depends_on = [google_project_service.cloudresourcemanager_project]
}

terraform {
  backend "gcs" {
  }
}