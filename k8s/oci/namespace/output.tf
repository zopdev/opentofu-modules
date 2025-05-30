output "namespace"{
  value = var.namespace
}

### DB Outputs
output "sql_instance_configs_v2" {
  value = {
    for key, db in var.sql_list : key => (
      db.type == "mysql" ? {
        instance_name     = module.sql_db[key].server_name
        instance_url      = module.sql_db[key].db_url
        type              = "mysql"
        version           = module.sql_db[key].db_version
        port              = module.sql_db[key].db_port
        storage           = module.sql_db[key].storage
        admin_user        = module.sql_db[key].db_admin_user
        admin_secret_name = "${key}-mysql-db-secret"
      } : (
      db.type == "postgresql" ? {
        instance_name     = module.psql_db[key].server_name
        instance_url      = module.psql_db[key].db_url
        type              = "postgres"
        version           = module.psql_db[key].db_version
        port              = module.psql_db[key].db_port
        admin_user        = module.psql_db[key].db_admin_user
        admin_secret_name = "${key}-postgres-db-secret"
      } : {}
      )
    )
  }
}

### Service Outputs
output "service_configs" {
  value = {
    for k, v in var.services : k => {
      db_name                              = try(v.datastore_configs.database, "")
      db_secret_name                       = try("${k}-${v.datastore_configs.database}-mysql-db-user", "")
      db_read_only_secret_name             = try("${k}-${v.datastore_configs.database}-mysql-readonly", "")
      db_user                              = try(
                                              v.datastore_configs.type == "mysql" ?
                                                module.sql_db[0].db_user["${var.namespace}-${v.datastore_configs.database}"] :
                                              (v.datastore_configs.type == "postgresql" ?
                                                module.psql_db[0].db_user["${var.namespace}-${v.datastore_configs.database}"] :
                                                ""),
                                              ""
                                            )
      custom_host_url                       = v.ingress_list != null ? (length(v.ingress_list) != 0 ? v.ingress_list : []) : []
      default_host_url                      = v.enable_default_ingress != null ? (
                                                v.enable_default_ingress ? kubernetes_ingress_v1.default_service_ingress["${k}-${var.namespace}-${local.default_domain_list[k].ingress[0]}"].spec[0].rule[0].host : ""
                                              ) : ""
      basic_auth_user_name                  = (v.enable_basic_auth != null ? v.enable_basic_auth : false) ? "${k}-${random_string.basic_auth_user_name_suffix[k].result}" : ""
      basic_auth_password                   = (v.enable_basic_auth != null ? v.enable_basic_auth : false) ? random_password.basic_auth_password[k].result : ""
      deployment_service_account_key     = {
        user_ocid       = oci_identity_user.artifact_user.id
        tenancy_ocid    = var.provider_id
        fingerprint     = oci_identity_api_key.artifact_user_api_key.fingerprint
        private_key     = tls_private_key.artifact_user_api_key.private_key_pem
        region          = var.app_region
        oar_username    = "${data.oci_objectstorage_namespace.tenancy_namespace.namespace}/${var.namespace}-artifact-user"
        oar_password    = oci_identity_auth_token.artifact_user_token.token
        cluster_ocid    = local.cluster_id
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
      db_name                              = try(v.datastore_configs.database, "")
      db_secret_name                       = try("${k}-${v.datastore_configs.database}-mysql-db-user", "")
      db_read_only_secret_name             = try("${k}-${v.datastore_configs.database}-mysql-readonly", "")
      db_user                              = try(
                                              v.datastore_configs.type == "mysql" ?
                                                module.sql_db[0].db_user["${var.namespace}-${v.datastore_configs.database}"] :
                                              (v.datastore_configs.type == "postgresql" ?
                                                module.psql_db[0].db_user["${var.namespace}-${v.datastore_configs.database}"] :
                                                ""),
                                              ""
                                            )
      deployment_service_account_key     = {
        user_ocid       = oci_identity_user.artifact_user.id
        tenancy_ocid    = var.provider_id
        fingerprint     = oci_identity_api_key.artifact_user_api_key.fingerprint
        private_key     = tls_private_key.artifact_user_api_key.private_key_pem
        region          = var.app_region
        oar_username    = "${data.oci_objectstorage_namespace.tenancy_namespace.namespace}/${var.namespace}-artifact-user"
        oar_password    = oci_identity_auth_token.artifact_user_token.token
        cluster_ocid    = local.cluster_id
      }
    }
  }
  sensitive = true
}
