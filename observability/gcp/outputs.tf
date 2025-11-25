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

