output "users_map" {
  value = {
   for k, v in var.users : v => {
     display_name        = azuread_user.aad_users[v].display_name
     user_principal_name = azuread_user.aad_users[v].user_principal_name
     object_id           = azuread_user.aad_users[v].object_id
     password            = azuread_user.aad_users[v].password
   }
 }
  sensitive = true
}