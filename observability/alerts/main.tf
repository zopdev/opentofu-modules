locals {
  configure_loki_alerts   = try(var.loki != null ? var.loki.enable : false, false)
  configure_tempo_alerts  = try(var.tempo != null ? var.tempo.enable : false, false)
  configure_cortex_alerts = try(var.cortex != null ? var.cortex.enable : false, false)
  configure_mimir_alerts  = try(var.mimir != null ? var.mimir.enable : false,false)
}