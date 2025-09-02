# Outputs for EKS Access Entries

output "access_entries_created" {
  description = "List of access entries that were created"
  value = {
    users = [for k, v in aws_eks_access_entry.users : {
      username      = v.username
      principal_arn = v.principal_arn
      groups        = v.kubernetes_groups
    }]
    karpenter_node_role = var.karpenter_node_role_name != null ? {
      principal_arn = aws_eks_access_entry.karpenter_node_role[0].principal_arn
      groups        = aws_eks_access_entry.karpenter_node_role[0].kubernetes_groups
    } : null
  }
}

output "access_policies_associated" {
  description = "List of access policies that were associated"
  value = {
    cluster_admin = [for k, v in aws_eks_access_policy_association.cluster_admin : {
      principal_arn = v.principal_arn
      policy_arn    = v.policy_arn
    }]
    cluster_viewer = [for k, v in aws_eks_access_policy_association.cluster_viewer : {
      principal_arn = v.principal_arn
      policy_arn    = v.policy_arn
    }]
    cluster_editor = [for k, v in aws_eks_access_policy_association.cluster_editor : {
      principal_arn = v.principal_arn
      policy_arn    = v.policy_arn
    }]
  }
}