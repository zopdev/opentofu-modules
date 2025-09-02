# EKS Access Entries Configuration
# This replaces the legacy aws-auth ConfigMap approach

locals {
  # Combine all users that need access
  all_users = concat(
    var.masters,
    var.editors, 
    var.viewers,
    var.system_authenticated_admins,
    var.system_authenticated_editors,
    var.system_authenticated_viewers
  )
  
  # Create access entries for all users
  user_access_entries = [
    for user in local.all_users : {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${user}"
      username      = user
      groups        = contains(var.masters, user) ? ["system:masters"] : (
                     contains(var.editors, user) ? ["cluster-editor"] : (
                     contains(var.viewers, user) ? ["cluster-viewer"] : (
                     contains(var.system_authenticated_admins, user) ? ["system:masters"] : (
                     contains(var.system_authenticated_editors, user) ? ["cluster-editor"] : (
                     contains(var.system_authenticated_viewers, user) ? ["cluster-viewer"] : []
                     )))))
    }
  ]
}

# Create EKS Access Entries for users
resource "aws_eks_access_entry" "users" {
  for_each = {
    for user in local.user_access_entries : user.username => user
  }

  cluster_name      = data.aws_eks_cluster.cluster.name
  principal_arn     = each.value.principal_arn
  type              = "STANDARD"
  kubernetes_groups = each.value.groups

  tags = {
    Name        = "${data.aws_eks_cluster.cluster.name}-access-entry-${each.value.username}"
    Environment = var.app_env
    ManagedBy   = "terraform"
  }
}

# Associate EKS Cluster Admin Policy for masters and system_authenticated_admins
resource "aws_eks_access_policy_association" "cluster_admin" {
  for_each = {
    for user in concat(var.masters, var.system_authenticated_admins) : user => user
  }

  cluster_name  = data.aws_eks_cluster.cluster.name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${each.value}"

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.users]
}

# Associate EKS View Policy for viewers and system_authenticated_viewers
resource "aws_eks_access_policy_association" "cluster_viewer" {
  for_each = {
    for user in concat(var.viewers, var.system_authenticated_viewers) : user => user
  }

  cluster_name  = data.aws_eks_cluster.cluster.name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${each.value}"

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterViewPolicy"
  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.users]
}

# Associate EKS Edit Policy for editors and system_authenticated_editors
resource "aws_eks_access_policy_association" "cluster_editor" {
  for_each = {
    for user in concat(var.editors, var.system_authenticated_editors) : user => user
  }

  cluster_name  = data.aws_eks_cluster.cluster.name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${each.value}"

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterEditPolicy"
  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.users]
}

# Create access entry for Karpenter node role if specified
resource "aws_eks_access_entry" "karpenter_node_role" {
  count = var.karpenter_node_role_name != null ? 1 : 0

  cluster_name      = data.aws_eks_cluster.cluster.name
  principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.karpenter_node_role_name}"
  type              = "EC2_LINUX"
  kubernetes_groups = ["system:bootstrappers", "system:nodes"]

  tags = {
    Name        = "${data.aws_eks_cluster.cluster.name}-karpenter-node-role"
    Environment = var.app_env
    ManagedBy   = "terraform"
  }
}