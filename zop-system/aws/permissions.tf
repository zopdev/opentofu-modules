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

resource "aws_iam_user" "zop_system_users" {
  name        = "zop-system-${random_string.iam_users_suffix.result}"
}

resource "aws_iam_access_key" "iam_users_access_keys" {
  user        = aws_iam_user.zop_system_users.name
}


resource "aws_iam_policy" "zop_system_permissions" {
  name  = "zop-system-permission_${var.cluster_name}"
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

resource "aws_iam_role" "zop_system_permissions" {
  name  = aws_iam_policy.zop_system_permissions.name
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
  name       = aws_iam_role.zop_system_permissions.name
  roles      = [aws_iam_role.zop_system_permissions.name]
  policy_arn = aws_iam_policy.zop_system_permissions.arn
  users      = [aws_iam_user.zop_system_users.name]
}

resource "random_password" "zop_system_api_key" {
  length = 12
}

resource "kubernetes_secret" "zop_system_secrets" {
  metadata {
    name      = "zop-system-secret"
    namespace = "zop-system"
  }
  data = {
    CREDENTIALS = jsonencode({"aws_access_key_id":aws_iam_access_key.iam_users_access_keys.id,"aws_secret_access_key":aws_iam_access_key.iam_users_access_keys.secret})
    X_API_KEY   = random_password.zop_system_api_key.result
  }
  depends_on = [kubernetes_namespace.app_environments]
}

data "google_secret_manager_secret_version" "zop_system_image_pull_secrets" {
  provider = google.shared-services
  secret  = "kops-kube-image-pull-secrets"
}

resource "kubernetes_secret_v1" "image_pull_secrets" {
  metadata {
    name = "zop-system-image-secrets"
    namespace = "zop-system"
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "us-central1-docker.pkg.dev" = {
          "username" = "_json_key"
          "password" = data.google_secret_manager_secret_version.zop_system_image_pull_secrets.secret_data
          "email"    = "image-pull@gcr"
        }
      }
    })
  }
  depends_on = [kubernetes_namespace.app_environments]
}

resource "kubernetes_service_account" "ksa_zop" {
  metadata {
    name      = "ksa-zop"
    namespace = "zop-system"
    
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.zop_system_permissions.arn
    }
  }
  depends_on = [kubernetes_namespace.app_environments]
}

resource "kubernetes_role" "zop_system_role" {
  metadata {
    name      = "zop-role"
  }

  rule {
    api_groups = [""]
    resources  = ["rbac"]
    verbs      = ["get", "list", "watch", "create", "delete"]
  }
}

resource "kubernetes_role_binding" "zop_role_binding" {
  metadata {
    name      = "zop-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.zop_system_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.ksa_zop.metadata[0].name
    namespace = kubernetes_service_account.ksa_zop.metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "zop_cluster_role_binding" {
  metadata {
    name = "zop-cluster-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.ksa_zop.metadata[0].name
    namespace = kubernetes_service_account.ksa_zop.metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "zop_cluster_role_binding" {
  metadata {
    name = "zop-cluster-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.ksa_zop.metadata[0].name
    namespace = kubernetes_service_account.ksa_zop.metadata[0].namespace
  }
}