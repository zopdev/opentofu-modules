locals {
  editor_passwords = {
    for db_key, secret in data.oci_secrets_secretbundle.postgres_db_editor_secret :
    db_key => base64decode(secret.secret_bundle_content[0].content)
  }

  readonly_passwords = {
    for db_key, secret in data.oci_secrets_secretbundle.postgres_db_readonly_secret :
    db_key => base64decode(secret.secret_bundle_content[0].content)
  }
}

resource "kubernetes_config_map" "postgres_db_init_script_create_db" {
  for_each = local.db_map

  metadata {
    name      = "postgres-db-config-${each.key}-create-db"
    namespace = "db"
  }

  data = {
    "db-init.sql" = templatefile("${path.module}/templates/postgres-db-init-create-database.sql",
      {
        database = each.value.db_name
      }
    )
  }
}

resource "kubernetes_secret" "postgres_db_init_script_master_password" {
  metadata {
    name      = "postgres-db-master-secret-${var.namespace}"
    namespace = "db"
  }

  type = "Opaque"

  data = {
    "password" = base64decode(data.oci_secrets_secretbundle.admin_password_bundle.secret_bundle_content[0].content)
  }
}

resource "kubernetes_secret" "postgres_db_init_script_create_role" {
  for_each = local.db_map

  metadata {
    name      = "postgres-db-secret-${replace(each.key, "_" , "-")}"
    namespace = "db"
  }

  type = "Opaque"

  data = {
    "db-init.sql" = templatefile("${path.module}/templates/postgres-db-init-create-role-readonly.sql",
      {
        database            = each.value.db_name
        username            = each.value.user
        admin_user          = var.administrator_login
        db_password         = local.editor_passwords[each.key]
        db_readonlypassword = local.readonly_passwords[each.key]
      }
    )
  }
}

resource "kubectl_manifest" "db_init_create_db" {
  depends_on = [
    kubernetes_secret.postgres_db_init_script_master_password,
    kubernetes_secret.postgres_db_init_script_create_role,
    oci_psql_db_system.postgres_db_system
  ]

  for_each  = local.db_map
  yaml_body = templatefile("${path.module}/templates/postgres-db-init-job.yaml",
    {
      db_host            = oci_psql_db_system.postgres_db_system.network_details[0].primary_db_endpoint_private_ip
      db_name            = each.value.db_name
      db_user            = oci_psql_db_system.postgres_db_system.admin_username
      db_port            = "5432"
      namespace          = "db"
      rds_name           = replace(each.key, "_" , "-")
      master_secret_name = "postgres-db-master-secret-${var.namespace}"
    }
  )
}
