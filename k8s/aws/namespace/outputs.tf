output "k8s_ca" {
  value = data.aws_eks_cluster.cluster.certificate_authority.0.data
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = data.aws_eks_cluster.cluster.endpoint
}

## DB Output Variables
output "sql_instance_configs" {
  value = var.sql_db != null ? {
    instance_name             = module.rds[0].db_name
    instance_url              = split(":", module.rds[0].db_url)[0]
    read_replica_instance_url = module.rds[0].rds_read_replica_db_url
    type                      = module.rds[0].db_type
    version                   = module.rds[0].db_version
    port                      = module.rds[0].db_port
    storage                   = module.rds[0].db_storage
    machine_type              = module.rds[0].db_instance_class
    admin_user                = module.rds[0].db_admin_user
    admin_secret_name         = "${local.cluster_name}-${var.namespace}-db-secret"
  } : {}
}

### Service Outputs
output "service_configs" {
  value = {
    for k, v in var.services : k =>
    {
      db_name                               = v.db_name != null ? v.db_name : ""
      db_secret_name                        = v.db_name != null ? "${local.cluster_name}-${var.namespace}-${v.db_name}-db-user-secret" : ""
      db_read_only_secret_name              = v.db_name != null ? "${local.cluster_name}-${var.namespace}-${v.db_name}-db-readonly-secret" : ""
      db_user                               = v.db_name != null ? module.rds[0].db_user["${var.namespace}-${v.db_name}"] : ""
      custom_host_url                       = v.ingress_list != null ? (length(v.ingress_list) != 0 ? v.ingress_list : []) : []
      default_host_url                      = v.enable_default_ingress != null ? ( v.enable_default_ingress ? kubernetes_ingress_v1.default_service_ingress["${k}-${var.namespace}-${local.default_domain_list[k].ingress[0]}"].spec[0].rule[0].host : "") : ""
      basic_auth_user_name                  = (v.enable_basic_auth != null ? v.enable_basic_auth : false) ? "${k}-${random_string.basic_auth_user_name_suffix[k].result}" : ""
      basic_auth_password                   = (v.enable_basic_auth != null ? v.enable_basic_auth : false) ? "${k}-${random_password.basic_auth_password[k].result}" : ""
    }
  }
  sensitive = true
}

output "cron_jobs_configs" {
  value = {
    for k, v in var.services : k =>
    {
      db_name                               = v.db_name != null ? v.db_name : ""
      db_secret_name                        = v.db_name != null ? "${local.cluster_name}-${var.namespace}-${v.db_name}-db-user-secret" : ""
      db_read_only_secret_name              = v.db_name != null ? "${local.cluster_name}-${var.namespace}-${v.db_name}-db-readonly-secret" : ""
      db_user                               = v.db_name != null ? module.rds[0].db_user["${var.namespace}-${v.db_name}"] : ""
    }
  }
  sensitive = true
}

output "dynamo_db_table_name" {
  value = tomap(
    {
    for k, v in module.dynamodb_table : "${var.namespace}-${k}" => v.dynamodb_table_id
    }
  )
}

output "dynamo_db_table_arn" {
  value = tomap(
    {
    for k, v in module.dynamodb_table : "${var.namespace}-${k}" => v.dynamodb_table_arn
    }
  )
}


output "dynamo_user_access_key" {
  value = tomap(
    {
    for k, v in aws_iam_access_key.dynamo_keys : (var.namespace) => try(jsondecode(aws_secretsmanager_secret_version.dynamo_db_secrets[0].secret_string).access_key, "null")
    }
  )
  sensitive = true
}

output "dynamo_user_secret_key" {
  value = tomap(
    {
    for k, v in aws_iam_access_key.dynamo_keys : (var.namespace) => "${local.cluster_name}-${var.namespace}-dynamo-user-secret-key"
    }
  )
  sensitive = true
}

output "custom_secrets_name_list" {
  value = tomap({
  for k, v in var.custom_namespace_secrets :  v=> "${local.cluster_name}-${var.namespace}-${v}-secret"
  })
}


output "namespace_user_access_keys" {
  description = "AWS access keys for namespace users"
  value = tomap({
    for service, user in aws_iam_user.namespace_users :
    "${service}-${var.namespace}-user" => {
      access_key_id     = aws_iam_access_key.namespace_user_keys[service].id
      secret_access_key = aws_iam_access_key.namespace_user_keys[service].secret
    }
  })
  sensitive = true
}