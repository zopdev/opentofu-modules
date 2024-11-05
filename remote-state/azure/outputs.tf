output "ca_certificate" {
  value = try(data.terraform_remote_state.infra_output.outputs.ca_certificate,"")
}

output "cluster_host" {
  value = try(data.terraform_remote_state.infra_output.outputs.cluster_host,"")
}

output "cluster_name" {
  value = try(data.terraform_remote_state.infra_output.outputs.cluster_name,"")
}

output "cluster_uid" {
  value = try(data.terraform_remote_state.infra_output.outputs.cluster_uid,"")
}

output "db_subnets" {
  value =  try(data.terraform_remote_state.infra_output.outputs.db_subnets,"")
}

output "kubernetes_endpoint" {
  value = try(data.terraform_remote_state.infra_output.outputs.kubernetes_endpoint,"")
}

output "oidc_role" {
  value = try(data.terraform_remote_state.infra_output.outputs.oidc_role,"")
}

output "private_subnets" {
  value =  try(data.terraform_remote_state.infra_output.outputs.private_subnets,"")
}

output "public_subnets" {
  value = try(data.terraform_remote_state.infra_output.outputs.public_subnets,"")
}

output "vpc_id" {
  value = try(data.terraform_remote_state.infra_output.outputs.vpc_id,"")
}

output "all_outputs" {
  value = try(data.terraform_remote_state.infra_output.outputs, "")
}

output "azurerm_key_vault_name" {
  value = try(data.terraform_remote_state.infra_output.outputs.azurerm_key_vault_name, "")
}