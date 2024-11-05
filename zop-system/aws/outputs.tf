output "zop_system" {
  value = {
    kube_management_api_user = aws_iam_user.zop_system_users.name
    zop_api_key     = random_password.zop_system_api_key.result
    kube_management_api_host        = "kube-management-api.${var.host}"
  }
  sensitive = true
}