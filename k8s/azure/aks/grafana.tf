locals {
  ### This is list of grafana datasources
  grafana_datasource_list   = try(var.observability_config.grafana.configs != null ? (var.observability_config.grafana.configs.datasource_list != null ? var.observability_config.grafana.configs.datasource_list : {}) : {}, {})
  grafana_db_deletion_protection = try(var.observability_config.grafana.configs != null ? (var.observability_config.grafana.persistence.deletion_protection != null ? var.observability_config.grafana.persistence.deletion_protection : true) : true, true)
  grafana_allowed_domains   = try(var.observability_config.grafana.configs != null ? (var.observability_config.grafana.configs.domains != null  ?  join(",", var.observability_config.grafana.configs.domains) : "") : "", "")
  grafana_enable            = try(var.observability_config.grafana != null ? var.observability_config.grafana.enable : false, false)
  grafana_host              = try(var.observability_config.grafana.url != null ? var.observability_config.grafana.url : (local.domain_name != "" ? "grafana.${local.domain_name}" : ""), "")

}

data "template_file" "grafana_template" {
  count = local.grafana_enable ? 1 : 0
  template = file("./templates/grafana-values.yaml")
  vars = {
    NAMESPACE                         = "monitoring"
    GRAFANA_HOST                      = local.grafana_host
    GRAFANA_ENABLED                   = local.grafana_enable
    GRAFANA_TLS_HOST                  = "*.${local.domain_name}"
    GRAFANA_OBS_ADMIN_PASSWORD        = try(local.grafana_enable ? try(random_password.observability_admin.0.result, "") : "", "")
    CLUSTER_NAME                      = var.app_name
    PERSISTENCE_TYPE_DB               = try(var.observability_config.grafana.persistence.type == "db" ? true : false, false)
    PERSISTENCE_TYPE_PVC              = try(var.observability_config.grafana.persistence.type == "pvc" ? true : false, false)
    PERSISTENCE_DISK_SIZE             = try(var.observability_config.grafana.persistence.disk_size != null ? var.observability_config.grafana.persistence.disk_size : "10Gi", "10Gi")
    GRAFANA_DB_NAME                   = try(local.grafana_enable && var.observability_config.grafana.persistence.type == "db" ? "grafana" : "", "")
    GRAFANA_DB_TYPE                   = try(local.grafana_enable && var.observability_config.grafana.persistence.type == "db" ? "postgres" : "", "")
    GRAFANA_DB_HOST                   = try(local.grafana_enable && var.observability_config.grafana.persistence.type == "db" ? module.grafana_db[0].db_url : "", "")
    GRAFANA_DB_PASSWORD               = try(local.grafana_enable && var.observability_config.grafana.persistence.type == "db" ? module.grafana_db[0].db_password : "", "")
    GRAFANA_DB_USER                   = try(local.grafana_enable && var.observability_config.grafana.persistence.type == "db" ? module.grafana_db[0].db_admin_user : "", "")
    GRAFANA_MIN_REPLICA               = try(var.observability_config.grafana.min_replica != null ? var.observability_config.grafana.min_replica : 1, 1)
    GRAFANA_MAX_REPLICA               = try(var.observability_config.grafana.max_replica != null ? var.observability_config.grafana.max_replica : 10, 10)
    GRAFANA_REQUEST_MEMORY            = try(var.observability_config.grafana.request_memory != null ? var.observability_config.grafana.request_memory : "100Mi", "100Mi")
    GRAFANA_REQUEST_CPU               = try( var.observability_config.grafana.request_cpu != null ? var.observability_config.grafana.request_cpu : "100m", "100m")
    GRAFANA_LIMIT_MEMORY              = try(var.observability_config.grafana.limit_memory != null ? var.observability_config.grafana.limit_memory: "500Mi", "500Mi")
    GRAFANA_LIMIT_CPU                 = try( var.observability_config.grafana.limit_cpu != null ? var.observability_config.grafana.limit_cpu : "500m", "500m")
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
    OAUTH_ID                          = try(var.observability_config.grafana.configs != null ? (var.observability_config.grafana.configs.enable_sso != null ? data.azurerm_key_vault_secret.oauth_client_id[0].value : null) : null, null)
    OAUTH_SECRET                      = try(var.observability_config.grafana.configs != null ? (var.observability_config.grafana.configs.enable_sso != null ? data.azurerm_key_vault_secret.oauth_client_secret[0].value : null) : null, null)
  }
}

resource "helm_release" "grafana" {
  count      = local.grafana_enable ? 1 : 0
  chart      = "grafana"
  name       = "grafana"
  namespace  = "monitoring"
  version    = "8.3.0"
  timeout    = 1200

  repository = "https://grafana.github.io/helm-charts"

  values = [
    data.template_file.grafana_template[count.index].rendered
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
  count = local.grafana_enable ? 1 : 0
  metadata {
    name      = "grafana-standard-datasource"
    namespace = helm_release.grafana[0].namespace
    labels    = {
      grafana_datasource = "1"
    }
  }

  data = {
    "datasource.yaml" = templatefile("./templates/grafana-standard-datasource.yaml",
      {
        datasource_name = local.cluster_name
        datasource_header_value = random_uuid.grafana_standard_datasource_header_value.result
        mimir_create      = local.enable_mimir
        loki_create       = local.enable_loki
        tempo_create      = local.enable_tempo
        cortex_create     = local.enable_cortex
        prometheus_create = local.prometheus_enable
      })
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


module "grafana_db" {
  source                     = "../../../sql/azure-postgres"
  count                      = try(local.grafana_enable && var.observability_config.grafana.persistence.type == "db" ? 1 : 0, 0)

  resource_group_name        = var.resource_group_name
  location                   = var.app_region
  cluster_name               = local.cluster_name
  namespace                  = "monitoring"
  administrator_login        =  "postgresadmin"
  databases                  = ["grafana"]
  postgres_server_name       = "${local.cluster_name}-monitoring-db"
  read_replica               =  false
  sku_name                   = "GP_Standard_D2s_v3"
  storage_mb                 = 32768
  key_vault_id               = azurerm_key_vault.secrets.id

  tags                  = local.common_tags
}

resource "kubernetes_service" "observability_db_service" {
  count       =  try(local.grafana_enable && var.observability_config.grafana.persistence.type == "db" ? 1 : 0, 0)
  metadata {
    name      = "monitoring-rds"
    namespace = "db"
  }
  spec {
    type          = "ExternalName"
    external_name = split(":", module.grafana_db[0].db_url)[0]
    port {
      port = module.grafana_db[0].db_port
    }
  }
}

data "azurerm_key_vault" "grafana_oauth" {
  count   = local.prometheus_enable && local.grafana_enable ? (var.observability_config.grafana.configs != null ? (var.observability_config.grafana.configs.enable_sso != null ? 1 : 0) : 0) : 0
  name                = "grafana-oauth"
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "oauth_client_id" {
  count   = local.prometheus_enable && local.grafana_enable ? (var.observability_config.grafana.configs != null ? (var.observability_config.grafana.configs.enable_sso != null ? 1 : 0) : 0) : 0
  name         = "${local.cluster_name}-oauth-client-id"
  key_vault_id = data.azurerm_key_vault.grafana_oauth[0].id
}

data "azurerm_key_vault_secret" "oauth_client_secret" {
  count   = local.prometheus_enable && local.grafana_enable ? (var.observability_config.grafana.configs != null ? (var.observability_config.grafana.configs.enable_sso != null ? 1 : 0) : 0) : 0
  name         = "${local.cluster_name}-oauth-client-secret"
  key_vault_id = data.azurerm_key_vault.grafana_oauth[0].id
}