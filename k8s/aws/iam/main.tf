resource "random_string" "iam_users_suffix" {
  length    = 6
  numeric   = true
  lower     = true
  upper     = false
  special   = false
 }

resource "random_password" "iam_user_password" {
  for_each  = {for k, v in var.users : v => k}
  length    = 12
}

resource "aws_iam_user" "iam_users" {
  for_each    = {for k, v in var.users : v => k}
  name        = "${replace(each.key, "@", "_")}_${random_string.iam_users_suffix.result}"
}

resource "aws_iam_access_key" "iam_users_access_keys" {
  for_each    = {for k, v in var.users : v => k}
  user        = aws_iam_user.iam_users[each.key].name
}