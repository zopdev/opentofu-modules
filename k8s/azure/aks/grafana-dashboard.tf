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
  for_each = toset(var.user_access.app_admins)
  length   = 16
  special  = true
}

resource "random_password" "editor_passwords" {
  for_each = toset(var.user_access.app_editors)
  length   = 16
  special  = true
}

resource "random_password" "viewer_passwords" {
  for_each = toset(var.user_access.app_viewers)
  length   = 16
  special  = true
}

resource "grafana_user" "admins" {
  for_each = toset(var.user_access.app_admins)
  name     = each.key
  email    = "${each.key}@gmail.com"
  login    = each.key
  password = random_password.admin_passwords[each.key].result
}

resource "grafana_user" "editors" {
  for_each = toset(var.user_access.app_editors)
  name     = each.key
  email    = "${each.key}@gmail.com"
  login    = each.key
  password = random_password.editor_passwords[each.key].result
}

resource "grafana_user" "viewers" {
  for_each = toset(var.user_access.app_viewers)
  name     = each.key
  email    = "${each.key}@gmail.com"
  login    = each.key
  password = random_password.viewer_passwords[each.key].result
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

resource "grafana_dashboard_permission_item" "admin_permissions" {
  for_each        = toset(var.user_access.app_admins)
  dashboard_uid   = grafana_dashboard.dashboard.uid
  user            = grafana_user.admins[each.key].id
  permission      = "Admin"
}

resource "grafana_dashboard_permission_item" "editor_permissions" {
  for_each        = toset(var.user_access.app_editors)
  dashboard_uid   = grafana_dashboard.dashboard.uid
  user            = grafana_user.editors[each.key].id
  permission      = "Editor"
}

resource "grafana_dashboard_permission_item" "viewer_permissions" {
  for_each        = toset(var.user_access.app_viewers)
  dashboard_uid   = grafana_dashboard.dashboard.uid
  user            = grafana_user.viewers[each.key].id
  permission      = "Viewer"
}

provider "grafana" {
  url   = "https://grafana.${local.cluster_name}.${var.accessibility.domain_name}"
  auth  = local.grafana_auth
}