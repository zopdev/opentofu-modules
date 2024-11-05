data "google_project" "this" {
}

resource "google_project_iam_member" "compute_instance_admin" {
  project     = var.provider_id
  role        = "roles/compute.instanceAdmin"
  member      = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_project_service.compute_project]
}

resource "google_project_iam_member" "cloud_sql" {
  project    = var.provider_id
  role       = "roles/cloudsql.client"
  member     = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_project_service.compute_project]
}

resource "google_project_iam_member" "dns"{
  project    = var.provider_id
  role       = "roles/dns.admin"
  member     = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_project_service.compute_project]
}

resource "google_project_iam_member" "logging" {
  project    = var.provider_id
  role       = "roles/logging.logWriter"
  member     = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_project_service.compute_project, google_project_iam_member.compute_instance_admin]
}

resource "google_project_iam_member" "artifact_reader" {
  project     = var.provider_id
  role        = "roles/artifactregistry.reader"
  member      = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_project_service.compute_project]
}

resource "google_project_iam_member" "compute_admin" {
  project     = var.provider_id
  role        = "roles/compute.loadBalancerAdmin"
  member      = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_project_service.compute_project]
}

resource "google_project_iam_member" "workload_identity" {
  project     = var.provider_id
  role        = "roles/iam.workloadIdentityUser"
  member      = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_project_service.compute_project]
}