# EKS Output Variables
output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.id
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.name
}

output "region" {
  description = "AWS region"
  value       = var.app_region
}

output "cluster_arn" {
  description = "EKS cluster ID."
  value       = module.eks.arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.endpoint
}


output "k8s_version" {
  value = "1.29"
}

output "os" {
  value = "Amazon Linux"
}

output "node_configs" {
  value = {
    machine_type   = var.node_config.node_type
    min_node_count = tostring(var.node_config.min_count)
    max_node_count = tostring(var.node_config.max_count)
  }
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.security_group_id
}

output "k8s_token" {
  value     = data.aws_eks_cluster_auth.cluster.token
  sensitive = true
}

output "k8s_ca" {
  value = module.eks.certificate_authority_data
}

output "oidc_role" {
  value = module.iam_assumable_role_admin.this_iam_role_arn
}

output "oidc_issuer_url" {
  value = module.eks.oidc_issuer_url
}

output "kafka_host" {
  value     = try(jsondecode(data.aws_secretsmanager_secret_version.kafka_secert_version.0.secret_string).kafka_host, "null")
  sensitive = true
}

output "kafka_password" {
  value     = "${local.cluster_name}-msk-secret"
  sensitive = true
}

output "kafka_username" {
  value     = try(jsondecode(data.aws_secretsmanager_secret_version.kafka_secert_version.0.secret_string).username, "null")
  sensitive = true
}

output "vpc_id" {
  value = local.vpc_id
}

output "db_subnets" {
  value = [for subnet in data.aws_subnet.db_subnet_cidrs : subnet.cidr_block]
}

output "private_subnets" {
  value = [for subnet in data.aws_subnet.private_subnet_cidrs : subnet.cidr_block]
}

output "public_subnets" {
  value = [for subnet in data.aws_subnet.public_subnet_cidrs : subnet.cidr_block]
}

output "db_subnets_id" {
  value = [for subnet in data.aws_subnet.db_subnet_cidrs : subnet.id]
}

output "private_subnets_id" {
  value = [for subnet in data.aws_subnet.private_subnet_cidrs : subnet.id]
}

output "public_subnets_id" {
  value = [for subnet in data.aws_subnet.public_subnet_cidrs : subnet.id]
}

output "mimir_host_url" {
  value = try(module.observability[0].mimir_host_url, "")
}

output "loki_host_url" {
  value = try(module.observability[0].loki_host_url, "")
}

output "cluster_uid" {
  value = random_uuid.grafana_standard_datasource_header_value.result
}

output "tempo_host_url" {
  value = try(module.observability[0].tempo_host_url, "")
}

output "cortex_host_url" {
  value = try(module.observability[0].cortex_host_url, "")
}

output "grafana_password" {
  sensitive = true
  value     = try(random_password.observability_admin[0].result, "")
}

output "grafana_admin" {
  value = local.grafana_enable ? "grafana-admin" : ""
}

output "grafana_host" {
  value = try(local.grafana_host, "")
}

output "grafana_datasources" {
  value     = local.grafana_datasource_list
  sensitive = true
}

output "lbip" {
  value = data.kubernetes_service.ingress-controller.status.0.load_balancer.0.ingress.0.hostname
}