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
  version = "21.0.0"

  name               = local.cluster_name
  kubernetes_version = "1.33"

  enable_irsa                              = true
  vpc_id                                   = local.vpc_id
  subnet_ids                               = local.private_subnet_ids
  control_plane_subnet_ids                 = local.private_subnet_ids
  enable_cluster_creator_admin_permissions = true

  # Enable node security group creation
  create_node_security_group = true

  # Enable Control Plane Logging
  enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Enable cluster secrets encryption
  encryption_config = {
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }

  # Endpoint access
  endpoint_private_access = false
  endpoint_public_access  = true

  self_managed_node_groups = {
    "${local.cluster_name}" = {
      ami_id        = data.aws_ssm_parameter.eks_ami.value
      instance_type = var.node_config.node_type
      desired_size  = var.node_config.min_count
      min_size      = var.node_config.min_count
      max_size      = var.node_config.max_count

      # Use module to create Access Entry but make it STANDARD (so policy assoc works)
      create_access_entry = true

      access_entry = {
        # STANDARD type required to associate access policies
        type = "STANDARD"
        # do NOT include kubernetes_groups that start with "system:" - AWS blocks that
        # If you include groups here they must NOT start with "system:"
      }

      access_policy_associations = {
        worker_node_policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSWorkerNodePolicy"
          access_scope = {
            type = "cluster"
          }
        }
        worker_node_bootstrap_policy = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSNodeBootstrapPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }

      launch_template = {
        metadata_options = {
          http_endpoint               = "enabled"
          http_tokens                 = "optional"
          http_put_response_hop_limit = 2
        }
      }

      autoscaling_group_tags = {
        "k8s.io/cluster-autoscaler/enabled"               = true
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
      }

      # AL2023 node bootstrap via nodeadm (recommended for AL2023 EKS-optimized AMIs)
      user_data = base64encode(<<-EOT
      #cloud-config
      ---
      nodeadm:
        apiVersion: node.eks.aws/v1alpha1
        kind: NodeConfig
        cluster:
          name: ${local.cluster_name}
          apiServerEndpoint: ${module.eks.cluster_endpoint}
          certificateAuthority: ${module.eks.cluster_certificate_authority_data}
        kubelet:
          config:
            # ensure this matches your cluster service CIDR's DNS (default often 10.100.0.10)
            clusterDNS: [10.100.0.10]
    EOT
      )

      # Node IAM policies (attach to node role). Keep minimal and correct:
      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        # don't add AmazonEKSClusterPolicy to node role (that's control-plane usage)
      }
    }
  }

  tags = merge(local.common_tags, {
    "Name" = local.cluster_name
  })

}

# -------------------------------------------------------------------
# VPC CNI Addon
# -------------------------------------------------------------------
data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = module.eks.cluster_version
  most_recent        = true
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = local.cluster_name
  addon_name               = "vpc-cni"
  addon_version            = data.aws_eks_addon_version.vpc_cni.version
  resolve_conflicts_on_create = "OVERWRITE"
  preserve                 = true
}

# -------------------------------------------------------------------
# SSM Parameter for EKS AL2023 AMI
# -------------------------------------------------------------------
data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/1.33/amazon-linux-2023/x86_64/standard/recommended/image_id"
}

# Access entries are handled internally by the EKS module for self-managed node groups