output "vcn_id" {
  value = local.vcn_id
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

output "db_subnets_id" {
  value = local.db_subnet_ids
}

output "endpoints" {
  value = module.oke.cluster_endpoints
}