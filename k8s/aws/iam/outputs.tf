output "users_map" {
  value = {
    for k, v in var.users : v => {
      user_name         = aws_iam_user.iam_users[v].name
      access_key_id     = aws_iam_access_key.iam_users_access_keys[v].id
      access_secret_key = aws_iam_access_key.iam_users_access_keys[v].secret
    }
  }
  sensitive = true
}