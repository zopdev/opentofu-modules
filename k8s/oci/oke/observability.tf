locals {
  enable_loki   = try(var.observability_config.loki != null ? var.observability_config.loki.enable : false, false)
  enable_tempo  = try(var.observability_config.tempo != null ? var.observability_config.tempo.enable : false, false)
  enable_cortex = try(var.observability_config.cortex != null ? var.observability_config.cortex.enable : false, false)
  enable_mimir  = try(var.observability_config.mimir != null ? var.observability_config.mimir.enable : false,false)
}

resource "oci_identity_user" "observability_user" {
  name           = "${local.cluster_name}-observability-user"
  description    = "User for observability access to Object Storage"
  email          = "${local.cluster_name}-observability@${local.domain_name}"
  compartment_id = var.provider_id
}

resource "oci_identity_group" "observability_group" {
  name           = "${local.cluster_name}-observability-group"
  description    = "Group for observability services"
  compartment_id = var.provider_id
}

resource "oci_identity_user_group_membership" "observability_user_membership" {
  user_id  = oci_identity_user.observability_user.id
  group_id = oci_identity_group.observability_group.id
}

resource "oci_identity_policy" "observability_policy" {
  name           = "${local.cluster_name}-observability-policy"
  description    = "Policy to allow Object Storage access for observability"
  compartment_id = var.provider_id
  statements = [
    "Allow group ${oci_identity_group.observability_group.name} to manage buckets in compartment id ${var.provider_id}",
    "Allow group ${oci_identity_group.observability_group.name} to manage objects in compartment id ${var.provider_id}"
  ]
}

resource "oci_identity_customer_secret_key" "observability_key" {
  user_id         = oci_identity_user.observability_user.id
  display_name    = "${local.cluster_name}-observability-secret"
}

data "oci_objectstorage_namespace" "tenancy_namespace" {
    compartment_id = var.provider_id
}

module "observability" {
  count       =  (local.enable_cortex || local.enable_loki || local.enable_tempo || local.enable_mimir) ? 1: 0
  source      = "../../../observability/oci"

  app_name             = var.app_name
  app_region           = var.app_region
  app_env              = var.app_env
  provider_id          = var.provider_id
  tenancy_namespace    = data.oci_objectstorage_namespace.tenancy_namespace.namespace
  observability_suffix = var.observability_config.suffix
  access_key           = oci_identity_customer_secret_key.observability_key.id
  access_secret        = oci_identity_customer_secret_key.observability_key.key
  domain_name          = local.domain_name
  cluster_name         = local.cluster_name
  loki                 = var.observability_config.loki
  tempo                = var.observability_config.tempo
  cortex               = var.observability_config.cortex
  mimir                = var.observability_config.mimir
  depends_on           = [helm_release.prometheus, helm_release.k8s_replicator]
}