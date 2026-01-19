locals {
  db_type = {
    "postgresql" = {
      type                                            = "postgres"
      enabled_cloudwatch_logs_exports                 = ["postgresql", "upgrade"]
      version                                         = var.sql_version != "" ? var.sql_version : "POSTGRES_14"
      port                                            = 5432
    }
    "mysql" = {
      type                                            = "mysql"
      enabled_cloudwatch_logs_exports                 = ["error", "slowquery"]
      version                                         = var.sql_version != "" ? var.sql_version : "MYSQL_8_0"
      port                                            = 3306
    }
  }
}

resource "google_compute_firewall" "sql-ingress-firewall" {
  name               = var.multi_ds ? "${var.app_uid}-${var.sql_name}-ingress" : "${var.app_uid}-ingress"
  description        = "${var.sql_name}-ingress-firewall"
  network            = var.vpc_name

  direction       = "INGRESS"

  allow {
    protocol        = "tcp"
    ports           = ["${local.db_type[var.sql_type].port}"]
  }

  source_ranges     = var.ext_rds_sg_cidr_block
}

resource "google_compute_firewall" "sql-egress-firewall" {
  name               = var.multi_ds ? "${var.app_uid}-${var.sql_name}-egress" : "${var.app_uid}-egress"
  network            = var.vpc_name

  direction       = "EGRESS"

  allow {
    protocol        = "tcp"
    ports           = ["${local.db_type[var.sql_type].port}"]
  }

  source_ranges     = var.ext_rds_sg_cidr_block
}

resource "google_sql_database_instance" "postgres_sql_db" {
  provider         = google-beta
  count            = var.sql_type == "postgresql" ? 1 : 0
  name             = var.sql_name
  project          = var.project_id
  region           = var.region
  database_version = local.db_type[var.sql_type].version
  root_password    = google_secret_manager_secret_version.db_secret.secret_data

  deletion_protection = var.deletion_protection

  settings {
    tier              = var.machine_type
    activation_policy = var.activation_policy
    disk_size         = var.disk_size
    disk_type         = var.disk_type
    availability_type = var.availability_type
    user_labels       = var.labels
    deletion_protection_enabled = var.deletion_protection

    ip_configuration {
      ipv4_enabled          = false
      private_network       = var.vpc_name
      require_ssl           = var.enable_ssl
    }

    backup_configuration {
      enabled                         = var.availability_type == "REGIONAL" ? true : false
      point_in_time_recovery_enabled  = var.availability_type == "REGIONAL" ? true : false
    }
  }

}

resource "google_sql_database_instance" "sql_db" {
  provider         = google-beta
  count            = var.sql_type == "mysql" ? 1 : 0
  name             = var.sql_name
  project          = var.project_id
  region           = var.region
  database_version = local.db_type[var.sql_type].version
  root_password    = google_secret_manager_secret_version.db_secret.secret_data

  deletion_protection = var.deletion_protection

  settings {
    tier              = var.machine_type
    activation_policy = var.activation_policy
    disk_size         = var.disk_size
    disk_type         = var.disk_type
    availability_type = var.availability_type
    user_labels       = var.labels
    deletion_protection_enabled = var.deletion_protection

    ip_configuration {
      ipv4_enabled          = false
      private_network       = var.vpc_name
      require_ssl           = var.enable_ssl
    }

    backup_configuration {
      binary_log_enabled              = var.availability_type == "REGIONAL" ? true : false
      enabled                         = var.availability_type == "REGIONAL" ? true : false
    }
  }

}

resource "google_sql_database" "sql_database" {
  for_each         = local.db_map
  name             = each.value.db_name
  project          = var.project_id
  instance         = var.sql_type == "postgresql" ? google_sql_database_instance.postgres_sql_db[0].name : google_sql_database_instance.sql_db[0].name
  charset          = "UTF8"
  collation        = var.db_collation
  lifecycle {
    ignore_changes = [
      charset,
      collation,
    ]
  }
}

resource "google_sql_user" "sql_user" {
  count    = var.sql_type == "mysql" ? 1 : 0
  name     = "mysqladmin"
  instance = google_sql_database_instance.sql_db[0].name
  host     = "10.0.0.0/8"
  password = google_secret_manager_secret_version.db_secret.secret_data
}

#REPLICATION
resource "google_sql_database_instance" "sql_db_replica" {
  count                 = var.read_replica ? 1 : 0
  provider              = google-beta
  name                  = "read-replica-${var.sql_name}"
  project               = var.project_id
  region                = var.region
  database_version      = local.db_type[var.sql_type].version
  deletion_protection   = var.deletion_protection
  master_instance_name  = var.sql_type == "postgresql" ? google_sql_database_instance.postgres_sql_db[0].name : google_sql_database_instance.sql_db[0].name

  settings {
    tier              = var.machine_type
    activation_policy = var.activation_policy
    disk_type         = var.disk_type
    availability_type = "ZONAL"
    user_labels       = var.labels
    deletion_protection_enabled = var.deletion_protection
  }
}


resource "google_sql_ssl_cert" "postgresql_db_cert" {
  count         = var.sql_type == "postgresql" && var.enable_ssl ? 1 : 0
  common_name   = "${google_sql_database_instance.postgres_sql_db[0].name}_${var.sql_type}_ssl_certificates"
  instance      = google_sql_database_instance.postgres_sql_db[0].name
  depends_on    = [google_sql_database_instance.postgres_sql_db]
}

resource "google_sql_ssl_cert" "sql_db_cert" {
  count         = var.sql_type == "mysql" && var.enable_ssl ? 1 : 0
  common_name   = "${google_sql_database_instance.sql_db[0].name}_${var.sql_type}_ssl_certificates"
  instance      = google_sql_database_instance.sql_db[0].name
  depends_on    = [google_sql_database_instance.sql_db]
}