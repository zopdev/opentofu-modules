output "kops_kube_user" {
  value = google_service_account.kops_kube_svc_acc.email
}

output "api_key" {
  value = random_password.kops_kube_api_key.result
  sensitive = true
}

output "host" {
  value = "kops-kube.${var.host}"
}

