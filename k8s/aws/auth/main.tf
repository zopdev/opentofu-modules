locals {
  system_authenticated_users = concat(var.system_authenticated_admins,var.system_authenticated_editors,var.system_authenticated_viewers)
}

data "aws_caller_identity" "current" {}

module "aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "20.0.0"

  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  // Organisation specific roles to be added for UI access.
  aws_auth_roles = concat(
    [
      {
        rolearn  = aws_iam_role.eks_cluster_admin.arn
        username = aws_iam_role.eks_cluster_admin.name
        groups   = ["system:masters"]
      },
      {
        rolearn  = aws_iam_role.eks_cluster_viewer.arn
        username = aws_iam_role.eks_cluster_viewer.name
        groups   = ["cluster-viewer"]
      },
      {
        rolearn  = aws_iam_role.eks_cluster_editor.arn
        username = aws_iam_role.eks_cluster_editor.name
        groups   = ["cluster-editor"]
      }
    ],
      var.karpenter_node_role_name != null ? [
      {
        rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.karpenter_node_role_name}"
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ] : []
  )

  aws_auth_users = concat(
      var.masters != null ? [
        for user in var.masters :
        {
          userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${user}"
          username = user
          groups   = ["system:masters"]
        }
      ]: [],
      var.viewers != null ? [
        for user in var.viewers :
        {
          userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${user}"
          username = user
          groups   = ["cluster-viewer"]
        }
      ] : [],
      var.editors != null ? [
        for user in var.editors :
        {
          userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${user}"
          username = user
          groups   = ["cluster-editor"]
        }
      ] : [],
      local.system_authenticated_users != null ? [
        for user in local.system_authenticated_users :
        {
          userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${user}"
          username = user
          groups   = []
        }
      ] : []
    )
}