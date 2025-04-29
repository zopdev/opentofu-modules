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
  
  role_map = {
    app_admins  = "Admin"
    app_editors = "Editor"
    app_viewers = "Viewer"
  }

  users_with_roles = flatten([
    for role, emails in var.user_access : [
      for email in emails : {
        email = email
        role  = local.role_map[role]
      }
    ]
  ])

  users_with_roles_map = {
    for user in local.users_with_roles : user.email => user
  }
}

resource "null_resource" "wait_for_grafana" {
  provisioner "local-exec" {
    command = <<-EOT
    sleep 10
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [
    helm_release.grafana,
    module.nginx,
    helm_release.k8s_replicator,
    kubernetes_secret_v1.certificate_replicator
  ]
}

resource "random_password" "admin_passwords" {
  for_each = coalesce(toset(var.user_access.app_admins), toset([]))
  length   = 12
  special  = true
  override_special = "$"
}

resource "random_password" "editor_passwords" {
  for_each = coalesce(toset(var.user_access.app_editors), toset([]))
  length   = 12
  special  = true
  override_special = "$"
}

resource "random_password" "viewer_passwords" {
  for_each = coalesce(toset(var.user_access.app_viewers), toset([]))
  length   = 12
  special  = true
  override_special = "$"
}

resource "grafana_user" "admins" {
  for_each = coalesce(toset(var.user_access.app_admins), toset([]))
  name     = split("@", each.key)[0]
  email    = each.key
  login    = split("@", each.key)[0]
  password = random_password.admin_passwords[each.key].result
  is_admin = true

  depends_on = [ null_resource.wait_for_grafana ]
}

resource "grafana_user" "editors" {
  for_each = coalesce(toset(var.user_access.app_editors), toset([]))
  name     = split("@", each.key)[0]
  email    = each.key
  login    = split("@", each.key)[0]
  password = random_password.editor_passwords[each.key].result
  is_admin = false

  depends_on = [ null_resource.wait_for_grafana ]
}

resource "grafana_user" "viewers" {
  for_each = coalesce(toset(var.user_access.app_viewers), toset([]))
  name     = split("@", each.key)[0]
  email    = each.key
  login    = split("@", each.key)[0]
  password = random_password.viewer_passwords[each.key].result
  is_admin = false

  depends_on = [ null_resource.wait_for_grafana ]
}

resource "grafana_folder" "dashboard_folder" {
  for_each   = { for obj in local.folder_map : obj.folder => obj }
  title      = each.key
  depends_on = [helm_release.grafana]
}

resource "grafana_dashboard" "dashboard" {
  for_each    = local.dashboard_map
  config_json = file("./templates/${each.value.dashboard}.json")
  folder      = grafana_folder.dashboard_folder[each.value.folder].id
  depends_on  = [grafana_folder.dashboard_folder]
}

resource "grafana_api_key" "admin_token" {
  name = "terraform-admin-token"
  role = "Admin"

  depends_on = [ grafana_user.admins, grafana_user.editors, grafana_user.viewers ]
}

resource "null_resource" "update_user_roles" {
  for_each = {
    for user in local.users_with_roles : "${user.email}-${user.role}" => user
  }

  provisioner "local-exec" {  ## change this while testing in stage for the domain
    command = <<EOT
      email="${each.value.email}"
      role="${each.value.role}"
      domain="http://localhost:60025"  ## change this 
      token="${grafana_api_key.admin_token.key}"

      response=$(curl -s -H "Authorization: Bearer $token" \
              "http://localhost:60025/api/org/users")

      email_escaped=$(echo "$email" | sed 's/\./\\./g')

      user_id=$(echo "$response" | grep -o "{[^}]*\"email\":\"$email_escaped\"[^}]*}" | grep -o "\"userId\":[0-9]*" | grep -o "[0-9]*")
          
      if [ -z "$user_id" ]; then
        echo "User $email not found. You may want to add them first."
        exit 1
      fi

      # Update user role in the org
      curl -s -X PATCH "http://localhost:60025/api/org/users/$user_id" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "{\"role\": \"$role\"}" || exit 1
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [ grafana_user.admins, grafana_user.editors, grafana_user.viewers ]
}

provider "grafana" {
  url   = "http://localhost:60025/"
  auth  = local.grafana_auth
}