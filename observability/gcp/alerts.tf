module "observability_alerts" {
  source = "../alerts"

  cluster_name = local.cluster_name

  cortex = {
    enable = local.enable_cortex
    alerts = local.enable_cortex ? (var.cortex.alerts != null ? var.cortex.alerts : null) : null
  }
  loki   = {
    enable = local.enable_loki
    alerts = local.enable_loki ? (var.loki.alerts != null ? var.loki.alerts : null) : null
  }
  mimir  = {
    enable = local.enable_mimir
    alerts = local.enable_mimir ? (var.mimir.alerts != null ? var.mimir.alerts : null) : null
  }
  tempo  = {
    enable = local.enable_tempo
    alerts = local.enable_tempo ? (var.tempo.alerts != null ? var.tempo.alerts : null) : null
  }
  depends_on = [helm_release.loki, helm_release.tempo, helm_release.tempo, helm_release.cortex]
}