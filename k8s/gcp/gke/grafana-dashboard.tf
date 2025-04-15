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

# resource "null_resource" "wait_for_grafana" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       #!/bin/bash
      
#       DOMAIN_NAME="${local.domain_name}"
      
#       echo "Checking Grafana readiness for domain: $DOMAIN_NAME"
      
#       for i in {1..30}; do
#         echo "Checking Grafana login page..."
#         RESPONSE=$(curl -sk https://grafana.$DOMAIN_NAME/login || true)
        
#         if echo "$RESPONSE" | grep -q '<title>Grafana</title>'; then
#           echo "Grafana login page is reachable."
#           break
#         else
#           echo "Grafana UI not ready yet."
#         fi
        
#         if [ $i -eq 30 ]; then
#           echo "Grafana UI was not ready after 30 attempts."
#           exit 1
#         fi
        
#         echo "Waiting 10s before retrying..."
#         sleep 10
#       done
      
#       echo "Now waiting for TLS certificate to become valid..."
      
#       for j in {1..60}; do
#         echo "Certificate check attempt..."
#         CERT_HOSTNAME=$(echo | openssl s_client -connect grafana.$DOMAIN_NAME:443 -servername grafana.$DOMAIN_NAME 2>/dev/null \
#           | openssl x509 -noout -subject | grep -o 'CN=.*' | cut -d= -f2)
        
#         if echo "$CERT_HOSTNAME" | grep -q "$DOMAIN_NAME"; then
#           echo "TLS certificate is valid for grafana.$DOMAIN_NAME (CN: $CERT_HOSTNAME)"
#           exit 0
#         else
#           echo "Certificate not yet valid. Current CN: $CERT_HOSTNAME"
#         fi
        
#         echo "Waiting 10s before retrying certificate check..."
#         sleep 10
#       done
      
#       echo "TLS certificate did not become valid in the allowed time."
#       exit 1
#     EOT
#   }

#   depends_on = [
#     helm_release.grafana,
#     module.nginx,
#     kubectl_manifest.cluster_wildcard_certificate
#   ]
# }

resource "random_password" "admin_passwords" {
  for_each = coalesce(toset(var.user_access.app_admins), toset([]))
  length   = 16
  special  = true
}

resource "random_password" "editor_passwords" {
  for_each = coalesce(toset(var.user_access.app_editors), toset([]))
  length   = 16
  special  = true
}

resource "random_password" "viewer_passwords" {
  for_each = coalesce(toset(var.user_access.app_viewers), toset([]))
  length   = 16
  special  = true
}

resource "grafana_user" "admins" {
  for_each = coalesce(toset(var.user_access.app_admins), toset([]))
  name     = split("@", each.key)[0]
  email    = each.key
  login    = split("@", each.key)[0]
  password = random_password.admin_passwords[each.key].result
  is_admin = true

  depends_on = [
    helm_release.grafana,
    module.nginx,
    kubectl_manifest.cluster_wildcard_certificate
  ]
}

resource "grafana_user" "editors" {
  for_each = coalesce(toset(var.user_access.app_editors), toset([]))
  name     = split("@", each.key)[0]
  email    = each.key
  login    = split("@", each.key)[0]
  password = random_password.editor_passwords[each.key].result
  is_admin = false

  depends_on = [
    helm_release.grafana,
    module.nginx,
    kubectl_manifest.cluster_wildcard_certificate
  ]
}

resource "grafana_user" "viewers" {
  for_each = coalesce(toset(var.user_access.app_viewers), toset([]))
  name     = split("@", each.key)[0]
  email    = each.key
  login    = split("@", each.key)[0]
  password = random_password.viewer_passwords[each.key].result
  is_admin = false

  depends_on = [
    helm_release.grafana,
    module.nginx,
    kubectl_manifest.cluster_wildcard_certificate
  ]
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

provider "grafana" {
  url   = "https://grafana.${local.domain_name}"
  auth  = local.grafana_auth
}