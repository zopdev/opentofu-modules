output "vcn_id" {
  value = try(data.terraform_remote_state.infra_output.outputs.vcn_id,"")
}

output "ca_certificate" {
  value = try(data.terraform_remote_state.infra_output.outputs.ca_certificate,"")
}

output "cluster_name" {
  value = try(data.terraform_remote_state.infra_output.outputs.cluster_name,"")
}

output "cluster_id" {
  value = try(data.terraform_remote_state.infra_output.outputs.cluster_id,"")
}

output "db_subnets" {
  value =  try(data.terraform_remote_state.infra_output.outputs.db_subnets,"")
}

output "kubernetes_endpoint" {
  value = try(data.terraform_remote_state.infra_output.outputs.kubernetes_endpoint,"")
}

output "worker_subnet_id" {
  value =  try(data.terraform_remote_state.infra_output.outputs.worker_subnets_id,"")
}

output "publb_subnet_id" {
  value = try(data.terraform_remote_state.infra_output.outputs.publb_subnets_id,"")
}

output "all_outputs" {
  value = try(data.terraform_remote_state.infra_output.outputs, "")
}

output "kms_vault_id" {
  value = try(data.terraform_remote_state.infra_output.outputs.kms_vault_id, "")
}

output "kms_key_id" {
  value = try(data.terraform_remote_state.infra_output.outputs.kms_key_id, "")
}