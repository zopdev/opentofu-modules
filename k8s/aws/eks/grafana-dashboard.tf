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

resource "random_password" "admin_passwords" {
  for_each = coalesce(toset(var.grafana_access.grafana_admins), toset([]))
  length   = 16
  special  = true
}

resource "random_password" "editor_passwords" {
  for_each = coalesce(toset(var.grafana_access.grafana_editors), toset([]))
  length   = 16
  special  = true
}

resource "random_password" "viewer_passwords" {
  for_each = coalesce(toset(var.grafana_access.grafana_viewers), toset([]))
  length   = 16
  special  = true
}

resource "grafana_user" "admins" {
  for_each = coalesce(toset(var.grafana_access.grafana_admins), toset([]))
  name     = split("@", each.key)[0]
  email    = each.key
  login    = split("@", each.key)[0]
  password = random_password.admin_passwords[each.key].result
  is_admin = true

  depends_on = [helm_release.grafana]
}

resource "grafana_user" "editors" {
  for_each = coalesce(toset(var.grafana_access.grafana_editors), toset([]))
  name     = split("@", each.key)[0]
  email    = each.key
  login    = split("@", each.key)[0]
  password = random_password.editor_passwords[each.key].result
  is_admin = false

  depends_on = [helm_release.grafana]
}

resource "grafana_user" "viewers" {
  for_each = coalesce(toset(var.grafana_access.grafana_viewers), toset([]))
  name     = split("@", each.key)[0]
  email    = each.key
  login    = split("@", each.key)[0]
  password = random_password.viewer_passwords[each.key].result
  is_admin = false

  depends_on = [helm_release.grafana]
}

resource "grafana_folder" "dashboard_folder" {
  for_each   = { for obj in local.folder_map : obj.folder => obj }
  title      = each.value.folder
  depends_on = [helm_release.grafana]
}

resource "grafana_dashboard" "dashboard" {
  for_each    = local.dashboard_map
  config_json = file("./templates/${each.value.dashboard}.json")
  folder      = grafana_folder.dashboard_folder[each.value.folder].id
  depends_on  = [grafana_folder.dashboard_folder]
}

provider "grafana" {
  url   = "https://grafana.${local.domain_name}"
  auth  = local.grafana_auth
}