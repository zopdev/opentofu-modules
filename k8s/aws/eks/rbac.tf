data "aws_caller_identity" "current" {}

/*
resource "aws_iam_policy" "admin_policy" {
  name = "${local.cluster_name}-k8sAdmins-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "iam:PassRole"
        Effect   = "Allow"
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "eks.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow",
        Action = [
          "eks:*",
        ],
        Resource = "*"
      }
    ]
  })
}
  resource "aws_iam_role_policy_attachment" "admin_policy" {
  for_each   = { for key, id in ["AAD_Admin"] : key => id }
  policy_arn = aws_iam_policy.admin_policy.arn
  role       = each.value
}
resource "aws_iam_policy" "dev_policy" {
  name = "${local.cluster_name}-k8sDevs-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeCluster",
          "eks:AccessKubernetesApi",
          "ssm:GetParameter",
          "eks:ListClusters",
          "eks:ListUpdates",
          "eks:ListFargateProfiles"
        ],
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "dev_policy" {
  for_each   = { for key, id in ["AAD_Devops", "AAD_ReadOnly"] : key => id }
  policy_arn = aws_iam_policy.dev_policy.arn
  role       = each.value
}
*/
resource "kubernetes_cluster_role_binding" "editor" {
  metadata {
    name = "cluster-editor"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }
  subject {
    kind = "Group"
    name = "cluster-editor"
  }
  depends_on = [module.eks]
}

resource "kubernetes_cluster_role_binding" "viewer" {
  metadata {
    name = "cluster-viewer"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    kind = "Group"
    name = "cluster-viewer"
  }
  depends_on = [module.eks]
}