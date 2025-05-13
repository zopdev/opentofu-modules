resource "oci_psql_db_system" "postgres_db_system" {
    display_name                   = var.postgres_db_system_name
    compartment_id                 = var.provider_id
    db_version                     = var.psql_version
    shape                          = var.postgres_shape_name
    instance_count                 = var.instance_count

    credentials {
        password_details {
            password_type = "PLAIN_TEXT"
            password      = base64decode(data.oci_secrets_secretbundle.admin_password_bundle.secret_bundle_content[0].content)
        }
        username          = var.administrator_login
    }
    network_details {
        subnet_id         = var.subnet_id
     }
    storage_details {
        is_regionally_durable = false
        system_type           = var.system_type
        availability_domain   = var.availability_domain
        iops                  = var.iops
    }
}
