locals {
  service_gar_name_map = {
    for key, config in var.services : key => coalesce(config.gar_name, key)
  }

  cronjob_gar_name_map = {
    for key, config in var.cron_jobs : key => coalesce(config.gar_name, key)
  }

  gar_name_map = merge(local.service_gar_name_map, local.cronjob_gar_name_map)

  user_repos = flatten([
    for service_key, service_config in var.services : [
      for user_id in var.artifact_users : "${coalesce(service_config.gar_name, service_key)}:${user_id}"
    ]
  ])
}

resource "kubernetes_namespace" "app_environments" {

  metadata {
    name = var.namespace
    labels = {
      "istio-injection" = "enabled"
    }
  }
  

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "random_string" "namespace_uid" {
  length   = 16
  numeric  = true
  lower    = true
  upper    = false
  special  = false
}

resource "random_string" "service_account_name" {
  for_each = local.gar_name_map
  length   = 16
  numeric  = true
  lower    = true
  upper    = false
  special  = false
}

resource "google_service_account" "service_deployment_svc_acc" {
  for_each     = local.gar_name_map
  project      = var.provider_id
  account_id   = regex("[a-z][-a-z0-9]{4,29}", random_string.service_account_name[each.key].result)
  display_name = "${each.key}-svc-acc"
  description  = "Service Account with permissions of deployment in ${local.cluster_name} gke cluster, ${var.namespace} namespace for application ${each.key}"
}

resource "google_service_account_key" "service_deployment_svc_acc" {
  for_each           = local.gar_name_map
  service_account_id = google_service_account.service_deployment_svc_acc[each.key].email
}

resource "google_secret_manager_secret" "namespace_svc_acc" {
  for_each     = local.gar_name_map
  provider     = google-beta
  project      = var.provider_id
  secret_id    = "${local.cluster_name}-${var.namespace}-${each.key}-namespace-svc-acc-secret"
  labels       = local.common_tags

  replication {
    automatic   = true
  }
}

resource "google_secret_manager_secret_version" "namespace_svc_acc" {
  for_each       = local.gar_name_map
  secret         = google_secret_manager_secret.namespace_svc_acc[each.key].id
  secret_data    = base64decode(google_service_account_key.service_deployment_svc_acc[each.key].private_key)
  depends_on     = [google_secret_manager_secret.namespace_svc_acc]
}

resource "google_project_iam_member" "namespace_svc_acc_cluster" {
  for_each    = local.gar_name_map
  project     = var.provider_id
  role        = "roles/container.clusterViewer"
  member      = "serviceAccount:${google_service_account.service_deployment_svc_acc[each.key].email}"
}

resource "google_project_iam_member" "namespace_svc_acc_container" {
  for_each    = local.gar_name_map
  project     = var.provider_id
  role        = "roles/container.developer"
  member      = "serviceAccount:${google_service_account.service_deployment_svc_acc[each.key].email}"
}

resource "google_artifact_registry_repository_iam_member" "artifact_member" {
  for_each   = local.gar_name_map
  provider   = google.artifact-registry
  location   = var.artifact_registry_location
  repository = each.value
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.service_deployment_svc_acc[each.key].email}"
}

resource "google_artifact_registry_repository_iam_member" "user_artifact_member" {
  for_each   = toset(local.user_repos)
  provider   = google.artifact-registry
  location   = var.artifact_registry_location
  repository = split(":",each.value)[0]
  role       = "roles/artifactregistry.writer"
  member     = "user:${split(":",each.value)[1]}"
}

resource "kubernetes_secret" "namespace" {
  for_each = local.gar_name_map

  metadata {
    name      = "${var.namespace}-${each.key}-svc-account"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
  }
  data = {
    GCP_SERVICE_ACCOUNT_KEY = base64decode(google_service_account_key.service_deployment_svc_acc[each.key].private_key)
  }
}
