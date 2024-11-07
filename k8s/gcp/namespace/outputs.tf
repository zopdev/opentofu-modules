output "namespace"{
  value = var.namespace
}

### DB Outputs
output "sql_instance_configs" {
  value = var.sql_db != null ? {
    instance_name             = module.sql_db[0].db_name
    instance_url              = module.sql_db[0].db_url
    read_replica_instance_url = module.sql_db[0].read_replica_db_url
    type                      = module.sql_db[0].db_type
    port                      = module.sql_db[0].db_port
    storage                   = module.sql_db[0].db_storage
    machine_type              = module.sql_db[0].db_tier
    admin_user                = module.sql_db[0].db_admin_user
    admin_secret_name         = "${local.cluster_name}-${var.namespace}-db-secret"
  } : {}
}

### Service Outputs
output "service_configs" {
  value = {
    for k, v in var.services : k =>
    {
      db_name                               = v.db_name != null ? v.db_name : ""
      db_secret_name                        = v.db_name != null ? "${local.cluster_name}-${var.namespace}-${v.db_name}-db-user-secret" : ""
      db_read_only_secret_name              = v.db_name != null ? "${local.cluster_name}-${var.namespace}-${v.db_name}-db-readonly-secret" : ""
      db_user                               = v.db_name != null ? module.sql_db[0].db_user["${var.namespace}-${v.db_name}"] : ""
      custom_host_url                       = v.ingress_list != null ? (length(v.ingress_list) != 0 ? v.ingress_list : []) : []
      default_host_url                      = v.enable_default_ingress != null ? ( v.enable_default_ingress ? kubernetes_ingress_v1.default_service_ingress["${k}-${var.namespace}-${local.default_domain_list[k].ingress[0]}"].spec[0].rule[0].host : "") : ""
      deployment_permission_service_account = google_service_account.service_deployment_svc_acc[k].account_id
      basic_auth_user_name                  = (v.enable_basic_auth != null ? v.enable_basic_auth : false) ? "${k}-${random_string.basic_auth_user_name_suffix[k].result}" : ""
      basic_auth_password                   = (v.enable_basic_auth != null ? v.enable_basic_auth : false) ? random_password.basic_auth_password[k].result : ""
      deployment_service_account_key        = sensitive(google_service_account_key.service_deployment_svc_acc[k].private_key)
    }
  }
  sensitive = true
}

### Cron Jobs Outputs
output "cron_jobs_configs" {
  value = {
    for k, v in var.cron_jobs : k =>
    {
      db_name                               = v.db_name != null ? v.db_name : ""
      db_secret_name                        = v.db_name != null ? "${local.cluster_name}-${var.namespace}-${v.db_name}-db-user-secret" : ""
      db_read_only_secret_name              = v.db_name != null ? "${local.cluster_name}-${var.namespace}-${v.db_name}-db-readonly-secret" : ""
      db_user                               = v.db_name != null ? module.sql_db[0].db_user["${var.namespace}-${v.db_name}"] : ""
      deployment_permission_service_account = google_service_account.service_deployment_svc_acc[k].account_id
      deployment_service_account_key        = sensitive(google_service_account_key.service_deployment_svc_acc[k].private_key)
    }
  }
  sensitive = true
}

### Deployment Config Outputs
output "deployment_configs" {
  value = {
    for k, v in var.services : k =>
    {
      deployment_permission_service_account = google_service_account.service_deployment_svc_acc[k].account_id
      deployment_service_account_key        = sensitive(google_service_account_key.service_deployment_svc_acc[k].private_key)
    }
  }
  sensitive = true
}

output "cassandra_passwords" {
  value = var.cassandra_db != null ? module.cassandra[0].cassandra_passwords : ""
  sensitive = true
}

output "cassandra_host_url" {
  value =  var.cassandra_db != null ? module.cassandra[0].cassandra_host_url : ""
}

output "custom_secrets_name_list" {
  value = {
  for  secret_key in var.custom_namespace_secrets : secret_key =>
  "${local.cluster_name}-${var.namespace}-${secret_key}-secret" }
}