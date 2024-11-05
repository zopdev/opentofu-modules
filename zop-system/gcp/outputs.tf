output "zop_system" {
  value = {
    kube_management_api_user      = google_service_account.kube_management_api_svc_acc.email
    kube_management_api_key       = random_password.kube_management_api_api_key.result
    kube_management_api_host      = "kube-management-api.${var.host}"
  }

  sensitive = true
}

