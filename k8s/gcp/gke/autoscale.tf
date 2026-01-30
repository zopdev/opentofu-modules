locals {
  autoscale_template = templatefile(
    "${path.module}/templates/cluster-auto-scaler-values.yaml",
    {
      CLUSTER_NAME    = local.cluster_name
      SERVICE_ACCOUNT = google_service_account.cluster_autoscaler.email
      MIN_COUNT       = var.node_config.min_count
      MAX_COUNT       = var.node_config.max_count
    }
  )
}

resource "helm_release" "auto_scaler" {
  chart      = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.28.0"

  values = [local.autoscale_template]
}

resource "google_service_account" "cluster_autoscaler" {
  project      = var.provider_id
  account_id   = "${local.cluster_service_account_name}-autoscaler"
  display_name = "${local.cluster_name} Cluster Autoscaler Account"
  description = "Service Account created for Cluster Autoscaling in ${local.cluster_name} gke cluster"
}

resource "google_project_iam_custom_role" "autoscaler_role" {
  role_id = "${local.app_name_role}_ClusterautoscalerRole_${random_string.cluster_get_role.result}"
  title = "${var.app_name} cluster-autoscaler-role"
  permissions = [
    "compute.instances.list",
    "compute.instances.get",
    "compute.instanceGroups.list",
  ]
}

resource "google_project_iam_member" "autoscaler_role" {
  project  = var.provider_id
  role     = "projects/${var.provider_id}/roles/${google_project_iam_custom_role.autoscaler_role.role_id}"
  member   = "serviceAccount:${google_service_account.cluster_autoscaler.email}"
  depends_on = [google_project_iam_custom_role.autoscaler_role]
}


resource "google_project_iam_member" "cluster_autoscaler_instance_admin" {
  project     = var.provider_id
  role        = "roles/compute.instanceAdmin.v1"
  member      = "serviceAccount:${google_service_account.cluster_autoscaler.email}"
}

resource "google_project_iam_member" "cluster_autoscaler_workload_role" {
  project = var.provider_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${var.provider_id}.svc.id.goog[kube-system/${local.cluster_name}-gce-autoscaler]"
  depends_on = [helm_release.auto_scaler]
}
