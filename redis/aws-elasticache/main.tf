locals {
  cluster_prefix      = var.shared_services.cluster_prefix != null ? var.shared_services.cluster_prefix : "${var.provider_id}/${var.app_env}/${var.app_name}"
  oidc_role           = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].oidc_role : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].oidc_role : module.remote_state_azure_cluster[0].oidc_role)
  cluster_name        = var.app_env != "" ? "${var.app_name}-${var.app_env}" : "${var.app_name}"
  db_subnets_ids      = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].all_outputs.db_subnets_id : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].all_outputs.db_subnets_id : module.remote_state_azure_cluster[0].all_outputs.db_subnets_id)
  vpc_id              = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].vpc_id : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].vpc_id : module.remote_state_azure_cluster[0].vpc_id)
}

module "remote_state_gcp_cluster" {
  source         = "../../remote-state/gcp"
  count          = var.shared_services.type == "gcp" ? 1 : 0
  bucket_name    = var.shared_services.bucket
  bucket_prefix  = local.cluster_prefix
}

module "remote_state_aws_cluster" {
  source         = "../../remote-state/aws"
  count          = var.shared_services.type == "aws" ? 1 : 0
  bucket_name    = var.shared_services.bucket
  provider_id    = var.shared_services.profile
  bucket_prefix  = local.cluster_prefix
  location       = var.shared_services.location
}

module "remote_state_azure_cluster" {
  source          = "../../remote-state/azure"
  count           = var.shared_services.type == "azure" ? 1 : 0
  resource_group  = var.shared_services.resource_group
  storage_account = var.shared_services.storage_account
  container       = var.shared_services.container
  bucket_prefix   = local.cluster_prefix
}

data "aws_eks_cluster" "cluster" {
  name = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].cluster_name : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].cluster_name : module.remote_state_azure_cluster[0].cluster_name)
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].cluster_name : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].cluster_name : module.remote_state_azure_cluster[0].cluster_name)
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_vpc" "vpc" {
  id = local.vpc_id
}

resource "aws_security_group" "redis_group" {
  name_prefix = var.redis.name != "" && var.redis.name != null ? "${local.cluster_name}-${var.namespace}-${var.redis.name}-sg" : "${local.cluster_name}-${var.namespace}-sg"
  vpc_id      = local.vpc_id

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"

    cidr_blocks = [
      data.aws_vpc.vpc.cidr_block
    ]
  }

  egress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"

    cidr_blocks = [
      data.aws_vpc.vpc.cidr_block
    ]
  }

  tags = var.tags
}

# count specifies if `var.redis.num_node_groups` is greater than 1 it creates redis in cluster mode
resource "aws_elasticache_replication_group" "redis_cluster" {
  count                         = var.redis.num_node_groups > 1 ? 1 : 0
  multi_az_enabled              = true
  automatic_failover_enabled    = true
  at_rest_encryption_enabled    = true
  engine_version                = var.redis.engine_version
  security_group_ids            = [aws_security_group.redis_group.id]
  replication_group_id          = var.redis.name != "" && var.redis.name != null ? var.redis.name : "${local.cluster_name}-${var.namespace}-redis"
  description                   = "redis replication group"
  node_type                     = var.redis.node_type
  parameter_group_name          = "default.redis6.x.cluster.on"
  port                          = 6379
  subnet_group_name             = aws_elasticache_subnet_group.redis_subnets.name
  replicas_per_node_group       = var.redis.replicas_per_node_group
  num_node_groups               = var.redis.num_node_groups

  tags = var.tags
  security_group_names          = []
}

# count specifies if `var.redis.num_node_groups` is not greater than 1 it creates redis in non cluster mode
resource "aws_elasticache_replication_group" "redis" {
  count = var.redis.num_node_groups > 1 ? 0 : 1

  automatic_failover_enabled    = true
  multi_az_enabled              = true
  at_rest_encryption_enabled    = true
  engine_version                = var.redis.engine_version
  security_group_ids            = [aws_security_group.redis_group.id]
  replication_group_id          = var.redis.name != "" && var.redis.name != null ? var.redis.name : "${local.cluster_name}-${var.namespace}-redis"
  description                   = "redis replication group"
  node_type                     = var.redis.node_type
  num_cache_clusters            = var.redis.replicas_per_node_group
  parameter_group_name          = "default.redis6.x"
  port                          = 6379
  subnet_group_name             = aws_elasticache_subnet_group.redis_subnets.name
  tags                          = var.tags

  security_group_names          = []
}

resource "aws_elasticache_subnet_group" "redis_subnets" {
  name       = var.redis.name != "" && var.redis.name != null ? "${local.cluster_name}-${var.namespace}-${var.redis.name}-cache-subnet" : "${local.cluster_name}-${var.namespace}-cache-subnet"
  subnet_ids = local.db_subnets_ids
  tags       = var.tags
}

resource "kubernetes_service" "redis_service" {
  metadata {
    name      = var.redis.name != "" && var.redis.name != null ? "${var.redis.name}-${var.namespace}-redis" : "${var.namespace}-redis"
    namespace = var.namespace
  }
  spec {
    type          = "ExternalName"
    external_name = var.redis.num_node_groups > 1 ? aws_elasticache_replication_group.redis_cluster.0.configuration_endpoint_address : aws_elasticache_replication_group.redis.0.primary_endpoint_address
    port {
      port = var.redis.num_node_groups > 1 ? aws_elasticache_replication_group.redis_cluster.0.port : aws_elasticache_replication_group.redis.0.port
    }
  }
}
