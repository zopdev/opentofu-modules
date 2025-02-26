locals {
  enable_loki   = try(var.observability_config.loki != null ? var.observability_config.loki.enable : false, false)
  enable_tempo  = try(var.observability_config.tempo != null ? var.observability_config.tempo.enable : false, false)
  enable_cortex = try(var.observability_config.cortex != null ? var.observability_config.cortex.enable : false, false)
  enable_mimir  = try(var.observability_config.mimir != null ? var.observability_config.mimir.enable : false,false)
}

module "observability" {
  count       =  (local.enable_cortex || local.enable_loki || local.enable_tempo || local.enable_mimir) ? 1: 0

  source = "../../../observability/gcp"

  app_name                = var.app_name
  app_region              = var.app_region
  project_id              = var.provider_id
  app_env                 = var.app_env
  domain_name             = try(var.accessibility.domain_name != null ? var.accessibility.domain_name : "", "")
  hosted_zone             = try(var.accessibility.hosted_zone != null ? var.accessibility.hosted_zone : "", "")
  observability_suffix    = var.observability_config.suffix
  labels                  = local.common_tags
  loki                    = var.observability_config.loki
  tempo                   = var.observability_config.tempo
  cortex                  = var.observability_config.cortex
  mimir                   = var.observability_config.mimir
  service_account_name_prefix = local.cluster_service_account_name

  providers = {
    google  = google
    google.shared-services = google.shared-services
  }

  depends_on = [helm_release.prometheus, helm_release.k8s_replicator]
}


