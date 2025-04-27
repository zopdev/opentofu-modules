output "test_availability_domains" {
  value = data.oci_identity_availability_domains.availability_domains.availability_domains
}

output "sql_db_endpoints" {
  description = "MySQL DB System endpoints from each module instance"
  value = {
    for db_key, mod in module.sql_db : db_key => mod.endpoints_mysql
  }
}