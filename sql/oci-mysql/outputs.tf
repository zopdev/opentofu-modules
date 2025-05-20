output "endpoints_mysql" {
  value = oci_mysql_mysql_db_system.mysql_db_system.endpoints
}

output "db_admin_user" {
  value = oci_mysql_mysql_db_system.mysql_db_system.admin_username
}

output "db_password" {
  value     = data.oci_secrets_secretbundle.admin_password_bundle.secret_bundle_content[0].content
  sensitive = true
}

output "db_port" {
  value = "3306"
}

output "db_url" {
  value = oci_mysql_mysql_db_system.mysql_db_system.ip_address
}

output "server_name" {
  value = oci_mysql_mysql_db_system.mysql_db_system.display_name
}

output "server_id" {
  value = oci_mysql_mysql_db_system.mysql_db_system.id
}

output "db_version" {
  value = oci_mysql_mysql_db_system.mysql_db_system.mysql_version
}

output "storage" {
  value = oci_mysql_mysql_db_system.mysql_db_system.data_storage_size_in_gb
}

output "db_user" {
  value = {
    for k,v in local.db_map : k => v.user
  }
}