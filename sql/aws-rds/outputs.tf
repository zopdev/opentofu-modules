output "db_admin_user" {
  value = aws_db_instance.db_instance.username
}

output "db_password" {
  value     = aws_db_instance.db_instance.password
  sensitive = true
}

output "db_port" {
  value = aws_db_instance.db_instance.port
}

output "db_url" {
  value = aws_db_instance.db_instance.endpoint
}

output "db_name" {
  value = aws_db_instance.db_instance.identifier
}

output "rds_read_replica_db_url" {
  value = element(concat(aws_db_instance.rds_read_replica[*].endpoint, [""]), 0)
}

output "db_type" {
  value = aws_db_instance.db_instance.engine
}

output "db_version" {
  value = aws_db_instance.db_instance.engine_version
}

output "db_storage" {
  value = aws_db_instance.db_instance.allocated_storage
}

output "db_instance_class" {
  value = aws_db_instance.db_instance.instance_class
}

output "db_user" {
  value = { for k, v in local.db_map : k => v.user }
}