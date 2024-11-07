output "namespace"{
  value = var.namespace
}

### DB Outputs
output "sql_instance_configs" {
  value = var.sql_db != null ? (
  var.sql_db.type == "mysql" ? {
    instance_name             = module.mysql[0].db_name
    instance_url              = module.mysql[0].db_url
    type                      = "mysql"
    version                   = module.mysql[0].db_version
    port                      = module.mysql[0].db_port
    storage                   = module.mysql[0].storage
    machine_type              = module.mysql[0].sku_name
    admin_user                = module.mysql[0].db_admin_user
    admin_secret_name         = "${local.cluster_name}-${var.namespace}-db-secret"
  } :  (
  var.sql_db.type == "postgresql" ? {
    instance_name             = module.postgresql[0].db_name
    instance_url              = module.postgresql[0].db_url
    type                      = "postgres"
    version                   = module.postgresql[0].db_version
    port                      = module.postgresql[0].db_port
    storage                   = module.postgresql[0].storage
    machine_type              = module.postgresql[0].sku_name
    admin_user                = module.postgresql[0].db_admin_user
    admin_secret_name         = "${local.cluster_name}-${var.namespace}-db-secret"
  } : {})
  ) : {}
}

### Service Outputs
output "service_configs" {
  value = {
    for k, v in var.services : k =>
    {
      db_name                               = v.db_name != null ? v.db_name : ""
      db_secret_name                        = v.db_name != null ? "${local.cluster_name}-${var.namespace}-${v.db_name}-db-user-secret" : ""
      db_read_only_secret_name              = v.db_name != null ? "${local.cluster_name}-${var.namespace}-${v.db_name}-db-readonly-secret" : ""
      db_user                               = v.db_name != null ? var.sql_db.type == "mysql" ? module.mysql[0].db_user["${var.namespace}-${v.db_name}"] : (var.sql_db.type == "postgres" ?  module.postgresql[0].db_user["${var.namespace}-${v.db_name}"] : "" ) : ""
      custom_host_url                       = v.ingress_list != null ? (length(v.ingress_list) != 0 ? v.ingress_list : []) : []
      default_host_url                      = v.enable_default_ingress != null ? ( v.enable_default_ingress ? kubernetes_ingress_v1.default_service_ingress["${k}-${var.namespace}-${local.default_domain_list[k].ingress[0]}"].spec[0].rule[0].host : "") : ""
      acr_login_server                      = data.azurerm_container_registry.acr[k].login_server
      basic_auth_user_name                  = (v.enable_basic_auth != null ? v.enable_basic_auth : false) ? "${k}-${random_string.basic_auth_user_name_suffix[k].result}" : ""
      basic_auth_password                   = (v.enable_basic_auth != null ? v.enable_basic_auth : false) ? random_password.basic_auth_password[k].result : ""
      deployment_service_account_key     = {
        password       = azuread_service_principal_password.acr_sp_pwd[k].value
        subscriptionId = data.azurerm_subscription.current.subscription_id
        tenantId       = data.azurerm_subscription.current.tenant_id
        appId          = azuread_service_principal.acr_sp[k].application_id
      }
    }
  }
  sensitive = true
}


### Cron OutPuts
output "cron_jobs_configs" {
  value = {
    for k, v in var.cron_jobs : k =>
    {
      db_name                               = v.db_name != null ? v.db_name : ""
      db_secret_name                        = v.db_name != null ? "${local.cluster_name}-${var.namespace}-${v.db_name}-db-user-secret" : ""
      db_read_only_secret_name              = v.db_name != null ? "${local.cluster_name}-${var.namespace}-${v.db_name}-db-readonly-secret" : ""
      db_user                               = v.db_name != null ? var.sql_db.type == "mysql" ? module.mysql[0].db_user["${var.namespace}-${v.db_name}"] : (var.sql_db.type == "postgres" ?  module.postgresql[0].db_user["${var.namespace}-${v.db_name}"] : "" ) : ""
      acr_login_server                      = data.azurerm_container_registry.cron_acr[k].login_server
      deployment_service_account_key       = {
        password       = azuread_service_principal_password.cron_acr_sp_pwd[k].value
        subscriptionId = data.azurerm_subscription.current.subscription_id
        tenantId       = data.azurerm_subscription.current.tenant_id
        appId          = azuread_service_principal.cron_acr_sp[k].application_id
      }
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
