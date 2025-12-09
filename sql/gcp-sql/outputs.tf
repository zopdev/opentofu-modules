output "db_admin_user" {
  value = "postgres"
}

output "db_password" {
  value     = google_secret_manager_secret_version.db_secret.secret_data
  sensitive = true
}

output "db_port" {
  value = local.db_type[var.sql_type].port
}

output "db_url" {
  value = var.sql_type == "postgresql" ? google_sql_database_instance.postgres_sql_db[0].connection_name : google_sql_database_instance.sql_db[0].connection_name
}

output "db_name" {
  value = var.sql_type == "postgresql" ? google_sql_database_instance.postgres_sql_db[0].name : google_sql_database_instance.sql_db[0].name
}

output "read_replica_db_url" {
  value = var.read_replica == true ? google_sql_database_instance.sql_db_replica[0].connection_name : null
}

output "db_type" {
  value = local.db_type[var.sql_type].type
}

output "db_instance_ip" {
  value = var.sql_type == "postgresql" ? google_sql_database_instance.postgres_sql_db[0].private_ip_address : google_sql_database_instance.sql_db[0].private_ip_address
}

output "db_storage" {
  value = var.sql_type == "postgresql" ? google_sql_database_instance.postgres_sql_db[0].settings[0].disk_size : google_sql_database_instance.sql_db[0].settings[0].disk_size
}

output "db_tier" {
  value = var.sql_type == "postgresql" ? google_sql_database_instance.postgres_sql_db[0].settings[0].tier : google_sql_database_instance.sql_db[0].settings[0].tier
}

output "db_user" {
  value = { for k, v in local.db_map : k => v.user }
}
