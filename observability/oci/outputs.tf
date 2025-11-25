output "mimir_basic_auth_username" {
  description = "Mimir basic auth username"
  value       = local.enable_mimir ? random_password.mimir_basic_auth_username[0].result : null
  sensitive   = true
}

output "mimir_basic_auth_password" {
  description = "Mimir basic auth password"
  value       = local.enable_mimir ? random_password.mimir_basic_auth_password[0].result : null
  sensitive   = true
}

output "mimir_host_url" {
  value = local.enable_mimir ? ( local.enable_ingress_mimir ? kubernetes_ingress_v1.service_ingress["mimir-nginx-gateway:80-mimir"].spec[0].rule[0].host : "mimir-nginx-gateway.mimir:80") : ""
}

output "loki_host_url" {
  value = local.enable_loki ? ( local.enable_ingress_loki ? kubernetes_ingress_v1.service_ingress["loki-distributor:3100-loki"].spec[0].rule[0].host : "loki-distributor.loki:3100") : ""
}

output "tempo_host_url" {
  value = local.enable_tempo ? ( local.enable_ingress_tempo ? kubernetes_ingress_v1.service_ingress["tempo-distributor:9411-tempo"].spec[0].rule[0].host : "tempo-distributor.tempo:9411") : ""
}

output "cortex_host_url" {
  value = local.enable_cortex ? (local.enable_ingress_cortex ? kubernetes_ingress_v1.service_ingress["cortex-distributor:8080-cortex"].spec[0].rule[0].host : "cortex-distributor.cortex:8080") : ""
}

