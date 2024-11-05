locals {
  grafana_auth    = local.prometheus_enable && local.grafana_enable ? "grafana-admin:${random_password.observability_admin[0].result}" : ""
  folder_creation = false

  grafana_dashboard_folder = local.folder_creation ? {
    Kong                        = ["kong-official"]
    Partner_Standard_API        = ["partner-standard-api"]
    Disk_Utilization            = ["cortex-disk-utilization", "prometheus-disk-utilization"]
  } : {}

  folder_map = [
    for key, value in local.grafana_dashboard_folder :  {
      folder     = key
      dashboards = value
    }
  ]

  dashboard_map = merge([
    for key, value in local.folder_map : {
      for dashboard in value.dashboards : "${value.folder}-${dashboard}" =>  {
        folder    = value.folder
        dashboard = dashboard
      }
    }
  ]...)
}

resource "grafana_folder" "dashboard_folder" {
  for_each   = { for obj in local.folder_map : obj.folder => obj }
  title      = each.value.folder
  depends_on = [helm_release.prometheus]
}

resource "grafana_dashboard" "dashboard" {
  for_each    = local.dashboard_map
  config_json = file("./templates/${each.value.dashboard}.json")
  folder      = grafana_folder.dashboard_folder[each.value.folder].id
  depends_on  = [grafana_folder.dashboard_folder]
}

provider "grafana" {
  url   = "https://grafana.${local.cluster_name}.${var.accessibility.domain_name}"
  auth  = local.grafana_auth
}