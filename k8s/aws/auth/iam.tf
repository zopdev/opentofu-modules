locals {
  cluster_name = var.shared_services.type == "aws" ? module.remote_state_aws_cluster[0].cluster_name : (var.shared_services.type == "gcp" ? module.remote_state_gcp_cluster[0].cluster_name : module.remote_state_azure_cluster[0].cluster_name)

}

resource "aws_iam_policy" "eks_cluster_admin" {
  name  = "EKS_CLUSTER_ADMIN_${local.cluster_name}"
  description = "Admin IAM policy for Users to access EKS clusters"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid" : "Admin",
        "Effect" : "Allow",
        "Action" : [
          "eks:AccessKubernetesApi",
          "eks:CreateAddon",
          "eks:CreateCluster",
          "eks:CreateFargateProfile",
          "eks:CreateNodegroup",
          "eks:DeleteAddon",
          "eks:DeleteCluster",
          "eks:DeleteFargateProfile",
          "eks:DeleteNodegroup",
          "eks:DescribeAddon",
          "eks:DescribeCluster",
          "eks:DescribeFargateProfile",
          "eks:DescribeNodegroup",
          "eks:DescribeUpdate",
          "eks:GetParameter",
          "eks:ListFargateProfiles",
          "eks:ListNodegroups",
          "eks:ListTagsForResource",
          "eks:ListUpdates",
          "eks:ListClusters",
          "eks:UpdateAddon",
          "eks:UpdateClusterConfig",
          "eks:UpdateClusterVersion",
          "eks:UpdateNodegroupConfig",
          "eks:UpdateNodegroupVersion",
        ],
        "Resource": "*"
      }]
  })
}

resource "aws_iam_role" "eks_cluster_admin" {
  name  = aws_iam_policy.eks_cluster_admin.name
  description = "Admin IAM role for Users to access EKS clusters"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = aws_iam_policy.eks_cluster_admin.name
    Provisioner = var.provisioner
  }
}

resource "aws_iam_policy_attachment" "eks_cluster_admin" {
  name       = aws_iam_role.eks_cluster_admin.name
  roles      = [aws_iam_role.eks_cluster_admin.name]
  policy_arn = aws_iam_policy.eks_cluster_admin.arn
  users      = distinct(concat(var.system_authenticated_admins,var.masters))
}

resource "aws_iam_policy" "eks_cluster_editor" {
  name  = "EKS_CLUSTER_EDITOR_${local.cluster_name}"
  description = "Editor IAM policy for Users to access EKS clusters"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid" : "Editor",
        "Effect" : "Allow",
        "Action" : [
          "eks:AccessKubernetesApi",
          "eks:DescribeAddon",
          "eks:DescribeCluster",
          "eks:DescribeFargateProfile",
          "eks:DescribeNodegroup",
          "eks:DescribeUpdate",
          "eks:GetParameter",
          "eks:ListFargateProfiles",
          "eks:ListNodegroups",
          "eks:ListTagsForResource",
          "eks:ListUpdates",
          "eks:ListClusters",
          "eks:UpdateAddon",
          "eks:UpdateClusterConfig",
          "eks:UpdateClusterVersion",
          "eks:UpdateNodegroupConfig",
          "eks:UpdateNodegroupVersion",
        ],
        "Resource": "*"
      }]
  })
}

resource "aws_iam_role" "eks_cluster_editor" {
  name  = aws_iam_policy.eks_cluster_editor.name
  description = "Editor IAM role for Users to access EKS clusters"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = aws_iam_policy.eks_cluster_editor.name
    Provisioner = var.provisioner
  }
}

resource "aws_iam_policy_attachment" "eks_cluster_editor" {
  name       = aws_iam_policy.eks_cluster_editor.name
  roles      = [aws_iam_role.eks_cluster_editor.name]
  policy_arn = aws_iam_policy.eks_cluster_editor.arn
  users      = distinct(concat(var.system_authenticated_editors,var.editors))
}

resource "aws_iam_policy" "eks_cluster_viewer" {
  name  = "EKS_CLUSTER_VIEWER_${local.cluster_name}"
  description = "Viewer IAM policy for Users to access EKS clusters"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid" : "Viewer",
        "Effect" : "Allow",
        "Action" : [
          "eks:ListFargateProfiles",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeFargateProfile",
          "eks:ListTagsForResource",
          "eks:ListUpdates",
          "eks:DescribeUpdate",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "eks:GetParameter"
        ],
        "Resource": "*"
      }]
  })
}

resource "aws_iam_role" "eks_cluster_viewer" {
  name  = aws_iam_policy.eks_cluster_viewer.name
  description = "Viewer IAM role for Users to access EKS clusters"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
      ]
    })

  tags = {
    Name        = aws_iam_policy.eks_cluster_viewer.name
    Provisioner = var.provisioner
  }
}

resource "aws_iam_policy_attachment" "eks_cluster_viewer" {
  name       = aws_iam_policy.eks_cluster_viewer.name
  roles      = [aws_iam_role.eks_cluster_viewer.name]
  policy_arn = aws_iam_policy.eks_cluster_viewer.arn
  users      = distinct(concat(var.system_authenticated_viewers,var.viewers))
}

resource "aws_iam_role" "karpenter_node_role" {
  name = "KarpenterNodeRole-${local.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_pull" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}