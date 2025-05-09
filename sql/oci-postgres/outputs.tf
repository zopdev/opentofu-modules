output "endpoints_postgres" {
  value = oci_psql_db_system.postgres_db_system.network_details
}

output "db_admin_user" {
  value = oci_psql_db_system.postgres_db_system.admin_username
}

output "db_password" {
  value     = data.oci_secrets_secretbundle.admin_password_bundle.secret_bundle_content[0].content
  sensitive = true
}

output "db_port" {
  value = "5432"
}

output "db_url" {
  value = oci_psql_db_system.postgres_db_system.network_details[0].primary_db_endpoint_private_ip
}

output "server_name" {
  value = oci_psql_db_system.postgres_db_system.display_name
}

output "server_id" {
  value = oci_psql_db_system.postgres_db_system.id
}

output "db_version" {
  value = oci_psql_db_system.postgres_db_system.db_version
}

output "db_user" {
  value = {
    for k,v in local.db_map : k => v.user
  }
}
