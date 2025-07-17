locals {
  custom_secrets = merge([
    for k in keys(var.services) : tomap({
      for secret in var.services[k].custom_secrets : "${k}-${secret}" => {
        secret_name = secret
        service     = k
    }
    }) if var.services[k].custom_secrets != null
  ]...)

  cron_job_custom_secrets = merge([
    for k in keys(var.cron_jobs) : tomap({
      for secret in var.cron_jobs[k].custom_secrets : "${k}-${secret}" => {
        secret_name = secret
        cron_job     = k
      }
    }) if var.cron_jobs[k].custom_secrets != null
  ]...)
}

# Service account with access to fetch the GCP secrets in all environment namespace
resource "kubernetes_service_account" "secrets" {
  metadata {
    name      = "secrets-account"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = "${data.google_project.this.number}-compute@developer.gserviceaccount.com"
    }
  }
}

### Adds the secrets provider for the secrets initialized for the particular cluster in all namespace
resource "kubectl_manifest" "secrets_provider" {
  for_each = { for k,v in var.services : k => v }

  yaml_body = templatefile("${path.module}/templates/secret-provider-class.yaml",
    {
      secrets = jsonencode(concat(
        (each.value.db_name != null ? [{ key = "DB_PASSWORD" , value = "${local.cluster_name}-${var.namespace}-${each.value.db_name}-db-secret" }] : []),
        (each.value.datastore_configs != null ? [{ key = "DB_PASSWORD" , value = "${local.cluster_name}-${var.namespace}-${each.value.datastore_configs.databse}-db-secret" }] : []),
#        var.cassandra_db == null ? [] : ["${local.cluster_name}-${var.namespace}-cassandra-secret"],
        try([for secret in each.value.custom_secrets  : { key = secret, value = "${local.cluster_name}-${var.namespace}-${each.key}-${secret}-secret"}], []),
        try([for ns in var.custom_namespace_secrets : { key = ns , value = "${local.cluster_name}-${var.namespace}-${ns}-secret"}], []),
      ))
      namespace    = kubernetes_namespace.app_environments.metadata[0].name
      service_name = each.key
      provider_id  = data.google_project.this.number
      ingress_with_secret = try(each.value.ingress_with_secret, [])
    }
  )
}

### Adds the secrets provider for the secrets initialized for the particular cluster in all namespace
resource "kubectl_manifest" "secrets_provider_cron_jobs" {
  for_each = { for k,v in var.cron_jobs : k => v }

  yaml_body = templatefile("${path.module}/templates/secret-provider-class.yaml",
    {
      secrets = jsonencode(concat(
        (each.value.db_name != null ? [{ key = "DB_PASSWORD" , value = "${local.cluster_name}-${var.namespace}-${each.value.db_name}-db-secret" }] : []),
        (each.value.datastore_configs != null ? [{ key = "DB_PASSWORD" , value = "${local.cluster_name}-${var.namespace}-${replace(each.value.datastore_configs.databse,"_","-")}-db-secret" }] : []),
        #        var.cassandra_db == null ? [] : ["${local.cluster_name}-${var.namespace}-cassandra-secret"],
        try([for secret in each.value.custom_secrets  : { key = secret, value = "${local.cluster_name}-${var.namespace}-${each.key}-${secret}-secret"}], []),
        try([for ns in var.custom_namespace_secrets : { key = ns , value = "${local.cluster_name}-${var.namespace}-${ns}-secret"}], []),
      ))
      namespace    = kubernetes_namespace.app_environments.metadata[0].name
      service_name = each.key
      provider_id  = data.google_project.this.number
      ingress_with_secret = try(each.value.ingress_with_secret, [])
    }
  )
}

resource "google_project_iam_member" "workload_identity_secrets" {
  count       = var.namespace == null ? 0 : 1
  project     = var.provider_id
  role        = "roles/iam.workloadIdentityUser"
  member      = "serviceAccount:${var.provider_id}.svc.id.goog[${var.namespace}/secrets-account]"

  depends_on  = [kubernetes_service_account.secrets]
}

resource "random_password" "cassandra_password" {
  count    = var.cassandra_db == null ? 0 : 1
  length   = 16
  special  = false
}

resource "google_secret_manager_secret" "cassandra_secret" {
  count    = var.cassandra_db == null ? 0 : 1

  provider     = google-beta
  project      = var.provider_id
  secret_id    = "${local.cluster_name}-${var.cassandra_db}-cassandra-secret"
  labels       = local.common_tags

  replication {
    automatic   = true
  }
}

resource "google_secret_manager_secret_version" "cassandra_secret" {
  count    = var.cassandra_db == null ? 0 : 1

  secret         = google_secret_manager_secret.cassandra_secret[var.cassandra_db].id
  secret_data    = random_password.cassandra_password[var.cassandra_db].result
  depends_on     = [google_secret_manager_secret.cassandra_secret]
}

resource "google_secret_manager_secret_iam_member" "cassandra_secret" {
  count    = var.cassandra_db == null ? 0 : 1

  project   = var.provider_id
  secret_id = google_secret_manager_secret.cassandra_secret[var.cassandra_db].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret_iam_member" "custom_secrets" {
  for_each  = {for k, v in local.custom_secrets : k => v }
  project   = var.provider_id
  secret_id = "${local.cluster_name}-${var.namespace}-${each.value.service}-${each.value.secret_name}-secret"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret_iam_member" "cron_job_custom_secrets" {
  for_each  = {for k, v in local.cron_job_custom_secrets : k => v }
  project   = var.provider_id
  secret_id = "${local.cluster_name}-${var.namespace}-${each.value.cron_job}-${each.value.secret_name}-secret"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret_iam_member" "custom_namespace_secrets" {
  count     = length(var.custom_namespace_secrets)
  project   = var.provider_id
  secret_id = "${local.cluster_name}-${var.namespace}-${var.custom_namespace_secrets[count.index]}-secret"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
}