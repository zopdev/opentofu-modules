output "zop_system" {
  value = {
    kube_management_api_user  = oci_identity_user.zop_user.id
    kube_management_api_key   = random_password.zop_system_api_key.result
    kube_management_api_host  = "kube-management-api.${var.host}"
  }
  sensitive = true
}