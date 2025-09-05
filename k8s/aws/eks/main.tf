locals {
  cluster_name = var.app_env == "" ? var.app_name : "${var.app_name}-${var.app_env}"
  node_port    = 32443 # Node port which will be used by LB for exposure
  inbound_ip   = concat(["10.0.0.0/8"], var.custom_inbound_ip_range)

  cluster_name_parts = split("-", local.cluster_name)
  environment        = var.app_env == "" ? element(local.cluster_name_parts, length(local.cluster_name_parts) - 1) : var.app_env
  namespaces         = [for namespace in var.namespace_folder_list : split("/", namespace)[0]]
  common_tags = merge(var.common_tags,
    tomap({
      project     = try(var.standard_tags.project != null ? var.standard_tags.project : local.cluster_name, local.cluster_name)
      provisioner = try(var.standard_tags.provisioner != null ? var.standard_tags.provisioner : "zop-dev", "zop-dev")
  }))

  namespace_users = flatten([
    for key, value in var.app_namespaces : [
      for user in concat(value.admins, value.editors, value.viewers) :
      {
        namespace = key
        name      = user
      }
    ]
  ])

}

resource "tls_private_key" "global_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_kms_key" "eks" {
  description = "EKS Secret Encryption Key"
  tags        = local.common_tags
}

# -------------------------------------------------------------------
# EKS Cluster (Kubernetes 1.33)
# -------------------------------------------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.cluster_name
  kubernetes_version = "1.33"

  # EKS Addons
  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids

  self_managed_node_groups = {
    example = {
      ami_type      = "AL2023_x86_64_STANDARD"
      instance_type = var.node_config.node_type

      min_size = var.node_config.min_count
      max_size = var.node_config.max_count
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = var.node_config.min_count

      # This is not required - demonstrates how to pass additional configuration to nodeadm
      # Ref https://awslabs.github.io/amazon-eks-ami/nodeadm/doc/api/
      cloudinit_pre_nodeadm = [
        {
          content_type = "application/node.eks.aws"
          content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              kubelet:
                config:
                  shutdownGracePeriod: 30s
          EOT
        }
      ]
    }
  }

  tags = merge(local.common_tags, {
    "Name" = local.cluster_name
  })

}