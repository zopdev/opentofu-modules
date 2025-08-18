locals {
  ec2nodeclass_yaml = templatefile("./templates/karpenter-ec2-nodeclass.yaml", {
    CLUSTER_NAME = local.cluster_name
    NODE_ROLE    = module.karpenter.node_iam_role_name
  })

  nodepool_yaml = templatefile("./templates/karpenter-nodepool.yaml", {
    CPU_LIMIT      = var.node_config.cpu * var.node_config.max_count
    INSTANCE_TYPES = var.karpenter_configs.machine_types
    CAPACITY_TYPE  = var.karpenter_configs.capacity_types
  })
}

provider "aws" {
  region = var.app_region
}

resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = local.cluster_name
  region = var.app_region

  create_node_iam_role = true
  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEKSWorkerNodePolicy = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    AmazonEC2ContainerRegistryPullOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  }

  create_iam_role = true
  namespace       = "karpenter"
}

#-------------------
# nodeclass & nodepool

resource "kubernetes_manifest" "karpenter_nodeclass" {
  count    = var.karpenter_configs.enable ? 1 : 0
  manifest = yamldecode(local.ec2nodeclass_yaml)
}

resource "kubernetes_manifest" "karpenter_nodepool" {
  count    = var.karpenter_configs.enable ? 1 : 0
  manifest = yamldecode(local.nodepool_yaml)
}






