output "zop_system" {
  value = {
    kube_management_api_user = azuread_service_principal.zop_system_sp.id
    kube_management_api_key     = random_password.zop_system_api_key.result
    kube_management_api_host        = "kube-management-api.${var.host}"
  }
  sensitive = true
}