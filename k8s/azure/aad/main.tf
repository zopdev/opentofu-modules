data "azuread_domains" "aad_domains" {}

resource "random_string" "aad_users_suffix" {
  length    = 6
  numeric   = true
  lower     = true
  upper     = false
  special   = false
 }

resource "random_password" "add_user_password" {
  for_each            = {for k, v in var.users : v => k}
  length    = 12
  min_lower = 1
  min_upper = 1
  min_numeric = 1
  min_special = 1
}

resource "azuread_user" "aad_users" {
  for_each            = {for k, v in var.users : v => k}
  user_principal_name = "${replace(each.key, "@", "_")}_${random_string.aad_users_suffix.result}@${data.azuread_domains.aad_domains.domains.*.domain_name[0]}"
  display_name        = replace(split("@", each.key)[0], ".", "_")
  password            = random_password.add_user_password[each.key].result
}