resource "oci_mysql_mysql_db_system" "mysql_db_system" {
    display_name        = var.mysql_db_system_name
    availability_domain = var.availability_domain
    compartment_id      = var.provider_id
    shape_name          = var.mysql_shape_name
    subnet_id           = var.subnet_id

    admin_username      = var.administrator_login
    admin_password      = base64decode(data.oci_secrets_secretbundle.admin_password_bundle.secret_bundle_content[0].content)

    data_storage_size_in_gb = var.storage

    data_storage {
      is_auto_expand_storage_enabled = var.storage_scaling
      max_storage_size_in_gbs = var.storage <= 400 ? 32768 : var.storage <= 800 ? 65536 : var.storage <= 1200 ? 98304 : 131072
    }

    deletion_policy {
        is_delete_protected = var.deletion_protection
    } 

    backup_policy {
        is_enabled = true
        retention_in_days = var.backup_retention_days  
    }
}

resource "oci_mysql_replica" "read_replica" {
  count                     = var.read_replica ? 1 : 0
  
  db_system_id              = oci_mysql_mysql_db_system.mysql_db_system.id
  display_name              = "${var.mysql_db_system_name}-replica"
  is_delete_protected       = var.deletion_protection
}

resource "oci_mysql_mysql_configuration" "ssl_configuration" {
  count          = var.enable_ssl ? 1 : 0  
  compartment_id = var.provider_id
  display_name   = "ssl-enabled-mysql-config"
  shape_name     = var.mysql_shape_name

  variables  {
    require_secure_transport = true
  }
}