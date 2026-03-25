locals {
  enable_gcloud_monitoring = try(var.observability_config.grafana.gcloud_monitoring != null ? var.observability_config.grafana.gcloud_monitoring : false, false)
  grafana_db_deletion_protection = try(var.observability_config.grafana.configs != null ? (var.observability_config.grafana.persistence.deletion_protection != null ? var.observability_config.grafana.persistence.deletion_protection : true) : true, true)
  grafana_datasource_list   = try(var.observability_config.grafana.configs != null ? (var.observability_config.grafana.configs.datasource_list != null ? var.observability_config.grafana.configs.datasource_list : {}) : {}, {})
  grafana_allowed_domains   = try(var.observability_config.grafana.configs != null ? (var.observability_config.grafana.configs.domains != null  ?  join(",", var.observability_config.grafana.configs.domains) : "") : "", "")
  prometheus_enable         = try(var.observability_config.prometheus != null ? var.observability_config.prometheus.enable : true, true)
  grafana_enable            = try(var.observability_config.grafana != null ? var.observability_config.grafana.enable : false, false)
  grafana_host              = try(var.observability_config.grafana.url != null ? var.observability_config.grafana.url : (local.domain_name != "" ? "grafana.${local.domain_name}" : ""), "")

  # Google cloud monitoring local configs
  private_key_start = "-----BEGIN PRIVATE KEY-----"
  private_key_end   = "-----END PRIVATE KEY-----"
  private_key_with_suffix       = try(split(local.private_key_start,base64decode(google_service_account_key.cloud_monitoring_svc_acc[0].private_key) )[1],"")
  private_key = split(local.private_key_end,local.private_key_with_suffix )[0]

}

resource "random_password" "observability_admin" {
  count    = local.grafana_enable ?  1 : 0
  length   = 16
  special  = false
}

data "template_file" "grafana_template" {
  count = local.grafana_enable ? 1 : 0
  template = file("${path.module}/templates/grafana-values.yaml")
  vars = {
    NAMESPACE                         = "monitoring"
    GRAFANA_TLS_HOST                  = "*.${local.domain_name}"
    GRAFANA_HOST                      = local.grafana_host
    GRAFANA_ENABLED                   = local.grafana_enable
    GRAFANA_OBS_ADMIN_PASSWORD        = try(local.grafana_enable ? try(random_password.observability_admin.0.result, "") : "", "")
    PERSISTENCE_TYPE_DB               = try(var.observability_config.grafana.persistence.type == "db" ? true : false, false)
    PERSISTENCE_TYPE_PVC              = try(var.observability_config.grafana.persistence.type == "pvc" ? true : false, false)
    PERSISTENCE_DISK_SIZE             = try(var.observability_config.grafana.persistence.disk_size != null ? var.observability_config.grafana.persistence.disk_size : "10Gi", "10Gi")
    GRAFANA_DB_NAME                   = try(local.grafana_enable && var.observability_config.grafana.persistence.type == "db" ? "grafana" : "", "")
    GRAFANA_DB_TYPE                   = try(local.grafana_enable && var.observability_config.grafana.persistence.type == "db" ? module.sql_db[0].db_type : "", "")
    GRAFANA_DB_HOST                   = try(local.grafana_enable && var.observability_config.grafana.persistence.type == "db" ? module.sql_db[0].db_instance_ip : "", "")
    GRAFANA_DB_PASSWORD               = try(local.grafana_enable && var.observability_config.grafana.persistence.type == "db" ? module.sql_db[0].db_password : "", "")
    GRAFANA_DB_USER                   = try(local.grafana_enable && var.observability_config.grafana.persistence.type == "db" ? module.sql_db[0].db_admin_user : "", "")
    GRAFANA_MIN_REPLICA               = try(var.observability_config.grafana.min_replica != null ? var.observability_config.grafana.min_replica : 1, 1)
    GRAFANA_MAX_REPLICA               = try(var.observability_config.grafana.max_replica != null ? var.observability_config.grafana.max_replica : 10, 10)
    GRAFANA_REQUEST_MEMORY            = try(var.observability_config.grafana.request_memory != null ? var.observability_config.grafana.request_memory : "100Mi", "100Mi")
    GRAFANA_REQUEST_CPU               = try(var.observability_config.grafana.request_cpu != null ? var.observability_config.grafana.request_cpu : "100m", "100m")
    GRAFANA_DASHBOARD_LIMIT_MEMORY    = try(var.observability_config.grafana.dashboard.limit_memory != null ? var.observability_config.grafana.dashboard.limit_memory : "512Mi", "512Mi")
    GRAFANA_DASHBOARD_LIMIT_CPU       = try(var.observability_config.grafana.dashboard.limit_cpu != null ? var.observability_config.grafana.dashboard.limit_cpu : "512m", "512m")
    GRAFANA_DASHBOARD_REQUEST_MEMORY  = try(var.observability_config.grafana.dashboard.request_memory != null ? var.observability_config.grafana.dashboard.request_memory : "256Mi", "256Mi")
    GRAFANA_DASHBOARD_REQUEST_CPU     = try(var.observability_config.grafana.dashboard.request_cpu != null ? var.observability_config.grafana.dashboard.request_cpu : "256m", "256m")
    GRAFANA_DATASOURCE_LIMIT_MEMORY   = try(var.observability_config.grafana.datasource.limit_memory != null ? var.observability_config.grafana.datasource.limit_memory : "512Mi", "512Mi")
    GRAFANA_DATASOURCE_LIMIT_CPU      = try(var.observability_config.grafana.datasource.limit_cpu != null ? var.observability_config.grafana.datasource.limit_cpu : "512m", "512m")
    GRAFANA_DATASOURCE_REQUEST_MEMORY = try(var.observability_config.grafana.datasource.request_memory != null ? var.observability_config.grafana.datasource.request_memory : "256Mi", "256Mi")
    GRAFANA_DATASOURCE_REQUEST_CPU    = try(var.observability_config.grafana.datasource.request_cpu != null ? var.observability_config.grafana.datasource.request_cpu : "256m", "256m")
    ENABLE_SSO                        = try(var.observability_config.grafana.configs != null ? (var.observability_config.grafana.configs.enable_sso != null ? var.observability_config.grafana.configs.enable_sso : false) :false, false)
    ALLOWED_DOMAINS                   = local.grafana_enable ? local.grafana_allowed_domains : ""
    OAUTH_ID                          = try(var.observability_config.grafana.configs != null ? (var.observability_config.grafana.configs.enable_sso != null ? data.google_secret_manager_secret_version.oauth_client_id[0].secret_data : null) : null, null)
    OAUTH_SECRET                      = try(var.observability_config.grafana.configs != null ? (var.observability_config.grafana.configs.enable_sso != null ? data.google_secret_manager_secret_version.oauth_client_secret[0].secret_data : null) : null, null)
    USE_MONITORING_NODE_POOL          = try(local.enable_monitoring_node_pool == true ? local.enable_monitoring_node_pool : false , false)
  }
}

resource "helm_release" "grafana" {
  count = local.grafana_enable ? 1 : 0
  chart = "grafana"
  name  = "grafana-helm"
  namespace = kubernetes_namespace.monitoring.metadata.0.name
  version = try(var.observability_config.grafana.version != null ? var.observability_config.grafana.version : "8.3.0", "8.3.0")
  timeout = 1200

  repository = "https://grafana.github.io/helm-charts"

  values = [
    data.template_file.grafana_template[0].rendered
  ]
  depends_on = [helm_release.prometheus]
}

resource "kubernetes_config_map" "grafana_custom_datasource" {
  for_each = {for k,v in local.grafana_datasource_list : k => v}
  metadata {
    name     = "grafana-${each.key}-datasource"
    namespace = helm_release.grafana[0].namespace
    labels = {
      grafana_datasource = "1"
    }
  }

  data = {
    "datasource.yaml" = templatefile("${path.module}/templates/grafana-custom-datasource.yaml",
      {
        tempo_datasource = local.enable_tempo
        loki_datasource  = local.enable_loki
        mimir_datasource = local.enable_mimir
        datasource_name  = each.key
        datasource_header_value = each.value
      }
    )
  }
}

resource "random_uuid" "grafana_standard_datasource_header_value" {
}

resource "kubernetes_config_map" "grafana_standard_datasource" {
  count = local.prometheus_enable && local.grafana_enable ? 1 : 0
  metadata {
    name     = "grafana-standard-datasource"
    namespace = helm_release.grafana[0].namespace
    labels = {
      grafana_datasource = "1"
    }
  }

  data = {
    "datasource.yaml" = templatefile("./templates/grafana-standard-datasource.yaml",
      {
        datasource_name = local.cluster_name
        datasource_header_value = random_uuid.grafana_standard_datasource_header_value.result
        project_id = var.provider_id
        svc_account_id = try(google_service_account.cloud_monitoring_svc_acc[0].email,"")
        key = local.private_key
        gcloud_monitoring = local.enable_gcloud_monitoring
        mimir_create  = local.enable_mimir
        loki_create   = local.enable_loki
        tempo_create  = local.enable_tempo
        cortex_create = local.enable_cortex
        prometheus_create = local.prometheus_enable
      }
    )
  }
}

resource "kubernetes_config_map" "grafana_service_dashboard" {
  count = local.grafana_enable ? 1 : 0
  metadata {
    name      = "grafana-service-dashboard"
    namespace = helm_release.grafana[0].namespace
    labels    = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "kong.json"                               = file("./templates/kong-official.json")
    "cronjob.json"                            = file("./templates/cronjob.json")
    "partner-standard-api.json"               = file("./templates/partner-standard-api.json")
    "cortex-disk-utilization.json"            = file("./templates/cortex-disk-utilization.json")
    "prometheus-disk-utilization.json"        = file("./templates/prometheus-disk-utilization.json")
  }
}

data "google_secret_manager_secret_version" "oauth_client_id" {
  count   = local.prometheus_enable && local.grafana_enable ? (var.observability_config.grafana.configs != null ? (var.observability_config.grafana.configs.enable_sso != null ? 1 : 0) : 0) : 0
  secret  = "${local.cluster_name}-oauth-client-id"
}

data "google_secret_manager_secret_version" "oauth_client_secret" {
  count   = local.prometheus_enable && local.grafana_enable ? (var.observability_config.grafana.configs != null ? (var.observability_config.grafana.configs.enable_sso != null ? 1 : 0) : 0) : 0
  secret  = "${local.cluster_name}-oauth-client-secret"
}

resource "google_secret_manager_secret" "observability_admin" {
  count        =  local.grafana_enable ?  1 : 0
  provider     = google-beta
  project      = var.provider_id
  secret_id    = "${local.cluster_name}-grafana-admin-secret"
  labels       = local.common_tags

  replication {
    automatic   = true
  }
}

resource "google_secret_manager_secret_version" "observability_admin" {
  count       = local.grafana_enable ?  1 : 0

  secret      = google_secret_manager_secret.observability_admin[0].id
  secret_data = random_password.observability_admin[0].result
  depends_on  = [google_secret_manager_secret.observability_admin]
}

resource "google_secret_manager_secret_iam_member" "observability_admin" {
  count     =  local.grafana_enable ?  1 : 0

  project   = var.provider_id
  secret_id = google_secret_manager_secret.observability_admin[0].id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
}


resource "google_service_account" "cloud_monitoring_svc_acc" {
  count = local.enable_gcloud_monitoring ? 1 : 0
  project      = var.provider_id
  account_id   = "${local.cluster_service_account_name}-monitoring"
  display_name = "${local.cluster_name} gcloud monitoring"
  description  = "Service Account with the permissions for cloud monitoring"
}

resource "google_service_account_key" "cloud_monitoring_svc_acc" {
  count = local.enable_gcloud_monitoring ? 1 : 0
  service_account_id = google_service_account.cloud_monitoring_svc_acc[0].email
}

resource "google_secret_manager_secret" "cloud_monitoring_svc_acc" {
  count = local.enable_gcloud_monitoring ? 1 : 0
  provider     = google-beta
  project      = var.provider_id
  secret_id    = "${local.cluster_name}-cloud-monitoring-svc-acc-secret"
  labels       = local.common_tags

  replication {
    automatic   = true
  }
}

resource "google_secret_manager_secret_version" "cloud_monitoring_svc_acc" {
  count = local.enable_gcloud_monitoring ? 1 : 0
  secret         = google_secret_manager_secret.cloud_monitoring_svc_acc[0].id
  secret_data    = base64decode(google_service_account_key.cloud_monitoring_svc_acc[0].private_key)
  depends_on     = [google_secret_manager_secret.cloud_monitoring_svc_acc[0]]
}

resource "google_project_iam_member" "cloud_monitoring_svc_acc_cluster" {
  count = local.enable_gcloud_monitoring ? 1 : 0
  project     = var.provider_id
  role        = "roles/monitoring.viewer"
  member      = "serviceAccount:${google_service_account.cloud_monitoring_svc_acc[0].email}"

}

module "sql_db" {
  count          = try(local.grafana_enable && var.observability_config.grafana.persistence.type == "db" ? 1 : 0, 0)

  source         = "../../../sql/gcp-sql"

  project_id            = var.provider_id
  project_number        = data.google_project.this.number
  region                = var.app_region
  vpc_name              = data.google_compute_network.vpc.self_link
  cluster_name          = local.cluster_name
  namespace             = "monitoring"
  sql_name              = "${local.cluster_name}-monitoring-sql-db"
  sql_type              =  "postgresql"
  databases             = ["grafana"]
  machine_type          = "db-f1-micro"
  disk_size             = 10
  availability_type     = "ZONAL"
  deletion_protection   = local.grafana_db_deletion_protection
  read_replica          = false
  activation_policy     = "ALWAYS"
  labels                = local.common_tags
  enable_ssl            = false
}