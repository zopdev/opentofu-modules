output "vcn_id" {
  value = local.vcn_id
}

output "ca_certificate" {
  value = module.oke.cluster_ca_cert
}

output "lbip" {
  value = oci_core_public_ip.lb_public_ip.ip_address
}

output "cluster_name" {
  value = local.cluster_name
}

output "cluster_uid" {
  description = "Kubernetes Cluster Name"
  value = module.oke.cluster_id
}

output "os" {
  value = "Oracle Linux"
}

output "location" {
  description = "OCI location"
  value       = var.app_region
}

output "k8s_version" {
  value = "1.33.1"
}

output "node_configs" {
  value = {
    node_type      = var.node_config.node_type
    size           = tostring(var.node_config.size)
    memory         = tostring(var.node_config.memory)
  }
}

output "db_subnets_id" {
  value = local.db_subnet_ids
}

output "worker_subnets_id" {
  value = local.worker_subnet_ids
}

output "cp_subnets_id" {
  value = local.cp_subnet_ids
}

output "publb_subnets_id" {
  value = local.publb_subnet_ids
}

output "kubernetes_endpoint" {
  value = module.oke.cluster_endpoints
}

output "db_subnets" {
  value = local.db_subnet_ids
}

output "kms_vault_id" {
  value = oci_kms_vault.oci_vault.id
}

output "kms_key_id" {
  value = oci_kms_key.oci_key.id
}

output "grafana_admin" {
  value = local.grafana_enable ? "grafana-admin" : ""
}

output "grafana_password" {
  sensitive = true
  value     = try(random_password.observability_admin[0].result,"")
}

output "grafana_host" {
  value = try(local.grafana_host,"")
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