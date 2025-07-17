output "kubernetes_endpoint" {
  sensitive = true
  value     = module.gke.endpoint
}

output "client_token" {
  sensitive = true
  value     = base64encode(data.google_client_config.default.access_token)
}

output "ca_certificate" {
  sensitive = true
  value     = module.gke.ca_certificate
}

output "region" {
  description = "GCP region"
  value       = var.app_region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}
  
output "app_env"{
  value = var.app_env
}

output "k8s_version" {
  value = "1.27"
}

output "os" {
  value = "UBUNTU_CONTAINERD"
}

output "node_configs" {
  value = [
    {
      machine_type   = var.node_config.node_type
      min_node_count = tostring(var.node_config.min_count)
      max_node_count = tostring(var.node_config.max_count)
    },
    var.monitoring_node_config == null ? null : {
      machine_type   = var.monitoring_node_config.node_type
      min_node_count = tostring(var.monitoring_node_config.min_count)
      max_node_count = tostring(var.monitoring_node_config.max_count)
    }
  ]
}

output "cluster_get_role" {
  value = google_project_iam_custom_role.cluster_get_role.role_id
}

output "mimir_host_url" {
  value = try(module.observability[0].mimir_host_url,"")
}

output "loki_host_url" {
  value = try(module.observability[0].loki_host_url,"")
}

output "cluster_uid" {
  value = random_uuid.grafana_standard_datasource_header_value.result
}

output "tempo_host_url" {
  value = try(module.observability[0].tempo_host_url,"")
}

output "cortex_host_url" {
  value = try(module.observability[0].cortex_host_url,"")
}

output "grafana_password" {
  sensitive = true
  value = try(random_password.observability_admin[0].result,"")
}

output "grafana_admin" {
  value = local.grafana_enable ? "grafana-admin" : ""
}

output "grafana_host" {
  value = try(local.grafana_host,"")
}

output "grafana_datasources" {
  value = local.grafana_datasource_list
  sensitive = true
}

output "lbip" {
  value = google_compute_address.lb_ip_address.address
}

output "gchat" {
  value = local.google_chat_alerts
}

output "grafana_user_credentials" {
  value = merge(
    { for key, pwd in random_password.admin_passwords : key => {
      email    = key
      password = pwd.result
    }},
    { for key, pwd in random_password.editor_passwords : key => {
      email    = key
      password = pwd.result
    }},
    { for key, pwd in random_password.viewer_passwords : key => {
      email    = key
      password = pwd.result
    }}
  )
  sensitive = true
}