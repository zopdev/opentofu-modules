output "kops_kube_user" {
  value = aws_iam_user.kops_kube_users.name
}

output "api_key" {
  value = random_password.kops_kube_api_key.result
  sensitive = true
}

output "host" {
  value = "kops-kube.${var.host}"
}

