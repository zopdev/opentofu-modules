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
    grafana_admins =  "Admin"
    grafana_viewers = "Editor"
    grafana_editors = "Viewer"
  }

  users_with_roles = flatten([
    for role, emails in var.grafana_access: [
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
      #!/bin/bash
      
      DOMAIN_NAME="${var.accessibility.domain_name}"
      
      echo "Checking Grafana readiness for domain: $DOMAIN_NAME"
      
      for i in {1..30}; do
        echo "Checking Grafana login page..."
        RESPONSE=$(curl -sk https://grafana.$DOMAIN_NAME/login || true)
        
        if echo "$RESPONSE" | grep -q '<title>Grafana</title>'; then
          echo "Grafana login page is reachable."
          break
        else
          echo "Grafana UI not ready yet."
        fi
        
        if [ $i -eq 30 ]; then
          echo "Grafana UI was not ready after 30 attempts."
          exit 1
        fi
        
        echo "Waiting 10s before retrying..."
        sleep 10
      done
      
      echo "Validating TLS certificate..."
      for j in {1..60}; do
        echo "Certificate check attempt $j..."
        
        if curl -s --head -o /dev/null -w "%%{http_code}" https://grafana.$DOMAIN_NAME --connect-timeout 5 | grep -q "200\|302"; then
          echo "TLS certificate verified successfully!"
          exit 0
        else
          echo "Valid certificate not detected yet, retrying..."
        fi
        
        echo "Waiting 10s before retrying certificate check..."
        sleep 10
      done
      
      echo "TLS certificate validation failed after waiting."
      exit 1
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [
    helm_release.grafana,
    module.nginx,
    kubectl_manifest.cluster_wildcard_certificate,
    kubernetes_secret_v1.certificate_replicator,
    helm_release.k8s_replicator,
  ]
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

  depends_on = [ null_resource.wait_for_grafana ]
}

resource "grafana_user" "editors" {
  for_each = coalesce(toset(var.grafana_access.grafana_editors), toset([]))
  name     = split("@", each.key)[0]
  email    = each.key
  login    = split("@", each.key)[0]
  password = random_password.editor_passwords[each.key].result
  is_admin = false

  depends_on = [ null_resource.wait_for_grafana ]
}

resource "grafana_user" "viewers" {
  for_each = coalesce(toset(var.grafana_access.grafana_viewers), toset([]))
  name     = split("@", each.key)[0]
  email    = each.key
  login    = split("@", each.key)[0]
  password = random_password.viewer_passwords[each.key].result
  is_admin = false

  depends_on = [ null_resource.wait_for_grafana ]
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

resource "grafana_api_key" "admin_token" {
  name = "terraform-admin-token"
  role = "Admin"

  depends_on = [ grafana_user.admins, grafana_user.editors, grafana_user.viewers ]
}

resource "null_resource" "update_user_roles" {
  for_each = local.users_with_roles_map

  provisioner "local-exec" {
    command = <<EOT
      email="${each.value.email}"
      role="${each.value.role}"
      domain="${var.accessibility.domain_name}"
      token="${grafana_api_key.admin_token.key}"

      response=$(curl -s -H "Authorization: Bearer $token" \
              "https://grafana.$domain/api/org/users")

      email_escaped=$(echo "$email" | sed 's/\./\\./g')

      user_id=$(echo "$response" | grep -o "{[^}]*\"email\":\"$email_escaped\"[^}]*}" | grep -o "\"userId\":[0-9]*" | grep -o "[0-9]*")
          
      if [ -z "$user_id" ]; then
        echo "User $email not found. You may want to add them first."
        exit 1
      fi

      # Update user role in the org
      curl -s -X PATCH "https://grafana.$domain/api/org/users/$user_id" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "{\"role\": \"$role\"}" || exit 1
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [ grafana_user.admins, grafana_user.editors, grafana_user.viewers ]
}

provider "grafana" {
  url   = "https://grafana.${var.accessibility.domain_name}"
  auth  = local.grafana_auth
}