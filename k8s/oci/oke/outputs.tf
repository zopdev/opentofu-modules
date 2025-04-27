output "vcn_id" {
  value = local.vcn_id
}

output "ca_certificate" {
  value = module.oke.cluster_ca_cert
}

output "cluster_name" {
  value = local.cluster_name
}

output "cluster_id" {
  value = module.oke.cluster_id
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