output "kops_kube_user" {
  value = oci_identity_user.kops_kube.id
}

output "api_key" {
  value = random_password.kops_kube_api_key.result
  sensitive = true
}

output "host" {
  value = "kops-kube.${var.host}"
}