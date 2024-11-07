output "kops_kube_user" {
  value = azuread_service_principal.kops_kube_sp.id
}

output "api_key" {
  value = random_password.kops_kube_api_key.result
  sensitive = true
}

output "host" {
  value = "kops-kube.${var.host}"
}