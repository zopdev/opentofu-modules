resource "random_string" "iam_users_suffix" {
  length    = 6
  numeric   = true
  lower     = true
  upper     = false
  special   = false
}

resource "random_password" "iam_user_password" {
  length    = 12
  special = false
}

resource "aws_iam_user" "kops_kube_users" {
  name        = "kops-kube-${random_string.iam_users_suffix.result}"
}

resource "aws_iam_access_key" "iam_users_access_keys" {
  user        = aws_iam_user.kops_kube_users.name
}


resource "aws_iam_policy" "kops_kube_permissions" {
  name  = "kops-kube-permission_${var.cluster_name}"
  description = "IAM policy for Users to list and describe EKS clusters"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid" : "Admin",
        "Effect" : "Allow",
        "Action" : [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ],
        "Resource": "*"
      }]
  })
}

resource "aws_iam_role" "kops_kube_permissions" {
  name  = aws_iam_policy.kops_kube_permissions.name
  description = "IAM role for Users to list and describe EKS clusters"

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
}

resource "aws_iam_policy_attachment" "eks_cluster_admin" {
  name       = aws_iam_role.kops_kube_permissions.name
  roles      = [aws_iam_role.kops_kube_permissions.name]
  policy_arn = aws_iam_policy.kops_kube_permissions.arn
  users      = [aws_iam_user.kops_kube_users.name]
}

resource "random_password" "kops_kube_api_key" {
  length = 12
}

resource "kubernetes_secret" "kops_kube_secrets" {
  metadata {
    name      = "kops-kube-secret"
    namespace = "kube-system"
  }
  data = {
    CREDENTIALS = jsonencode({"aws_access_key_id":aws_iam_access_key.iam_users_access_keys.id,"aws_secret_access_key":aws_iam_access_key.iam_users_access_keys.secret})
    X_API_KEY   = random_password.kops_kube_api_key.result
  }
}

data "google_secret_manager_secret_version" "kops_kube_image_pull_secrets" {
  provider = google.shared-services
  secret  = "kops-kube-image-pull-secrets"
}

resource "kubernetes_secret_v1" "image_pull_secrets" {
  metadata {
    name = "kops-kube-image-secrets"
    namespace = "kube-system"
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "us-central1-docker.pkg.dev" = {
          "username" = "_json_key"
          "password" = data.google_secret_manager_secret_version.kops_kube_image_pull_secrets.secret_data
          "email"    = "image-pull@gcr"
        }
      }
    })
  }
}

resource "kubernetes_cluster_role" "kops_kube_reader" {
  metadata {
    name = "kops-kube-reader"
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["cronjobs"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "kops_kube_default_binding" {
  metadata {
    name = "kops-kube-default-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.kops_kube_reader.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }
}