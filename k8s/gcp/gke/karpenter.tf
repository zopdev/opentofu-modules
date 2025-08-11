# # gcloud services for karpenter to manage compute and Kubernetes resources
# resource "google_project_service" "compute_service" {
#   project = var.provider_id
#   service = "compute.googleapis.com"
#   disable_on_destroy = false
# }

# resource "google_project_service" "container_service" {
#   project = var.provider_id
#   service = "container.googleapis.com"
#   disable_on_destroy = false
# }

# gcloud service account for karpenter
resource "google_service_account" "karpenter" {
  count = var.karpenter_configs.enable ? 1 : 0
  project = var.provider_id
  account_id = "${local.cluster_service_account_name}-karpenter"
  display_name = "${local.cluster_name} Karpenter Account"
  description = "Service Account created for Karpenter in ${local.cluster_name} gke cluster"
}

# compute admin role
resource "google_project_iam_member" "compute_admin" {
  count = var.karpenter_configs.enable ? 1 : 0
  project = var.provider_id
  member = google_service_account.karpenter.member
  role = "roles/compute.admin"
}

# kubernetes engine admin role
resource "google_project_iam_member" "kubernetes_engine_admin" {
  count = var.karpenter_configs.enable ? 1 : 0
  project = var.provider_id
  member = google_service_account.karpenter.member
  role = "roles/container.admin"
}

# monitoring admin role
resource "google_project_iam_member" "monitoring_admin" {
  count = var.karpenter_configs.enable ? 1 : 0
  project = var.provider_id
  member = google_service_account.karpenter.member
  role = "roles/monitoring.admin"
}

# service account user role
resource "google_service_account_iam_member" "service_account_user" {
  count = var.karpenter_configs.enable ? 1 : 0
  service_account_id = google_service_account.karpenter.name
  member = google_service_account.karpenter.member
  role = "roles/iam.serviceAccountUser"
}

# namespace for karpenter
resource "kubernetes_namespace" "karpenter" {
  count = var.karpenter_configs.enable ? 1 : 0
  metadata {
    name = "karpenter"
  }
}

# get service account key
resource "google_service_account_key" "karpenter_key" {
  count = var.karpenter_configs.enable ? 1 : 0
  service_account_id = google_service_account.karpenter.name
}

# secret with service account key for karpenter
resource "kubernetes_secret" "gcp-credentials" {
  count = var.karpenter_configs.enable ? 1 : 0
  metadata {
    name = "karpenter-gcp-credentials"
    namespace = "karpenter"
  }

  data = {
    "key.json" = google_service_account_key.karpenter_key.private_key
  }
}

# helm chart values
data "template_file" "karpenter_template" {
  count = var.karpenter_configs.enable ? 1 : 0
  template = file("./templates/karpenter-values.yaml")
  vars = {
    PROJECT_ID      = var.provider_id
    REGION          = var.app_region
    CLUSTER_NAME    = local.cluster_name
    SECRET_NAME     = kubernetes_secret.gcp-credentials.metadata[0].name
  }
}

# helm chart install
resource "helm_release" "karpenter" {
  count = var.karpenter_configs.enable ? 1 : 0
  name = "karpenter"
  repository = "https://helm.zop.dev"
  chart = "karpenter-gcp"
  namespace = "karpenter"
  version = "0.0.1"

  values = [data.template_file.karpenter_template.rendered]
}

# available zones in region
data "google_compute_zones" "zones" {
  count = var.karpenter_configs.enable ? 1 : 0
  project = var.provider_id
  region  = var.app_region
}

# pass values to nodeClass and nodePool manifests
locals {
  nodeclass_yaml = var.karpenter_configs.enable ? templatefile("./templates/karpenter-gcp-nodeclass.yaml", {
    SERVICE_ACCOUNT = google_service_account.karpenter.email
    ENVIRONMENT = var.app_env
  }) : null

  nodepool_yaml = var.karpenter_configs.enable ? templatefile("./templates/karpenter-gcp-nodepool.yaml", {
    ZONES = data.google_compute_zones.zones.names
    INSTANCE_TYPES = var.karpenter_configs.machine_types
    CAPACITY_TYPES = var.karpenter_configs.capacity_types
  }) :  null
}

# deploy NodeClass
resource "kubernetes_manifest" "node_class" {
  count = var.karpenter_configs.enable ? 1 : 0
  depends_on = [helm_release.karpenter]
  manifest = yamldecode(local.nodeclass_yaml)
}

# deploy NodePool
resource "kubernetes_manifest" "node_pool" {
  count = var.karpenter_configs.enable ? 1 : 0
  depends_on = [helm_release.karpenter]
  manifest = yamldecode(local.nodepool_yaml)
}