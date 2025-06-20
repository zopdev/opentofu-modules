resource "aws_iam_user" "velero" {
  name = "${local.cluster_name}-velero-user"
  tags = local.common_tags
}

resource "aws_iam_user_policy" "velero" {
  name = "${local.cluster_name}-velero-policy"
  user = aws_iam_user.velero.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ],
        Resource = "arn:aws:s3:::*/*"
      },
      {
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = "arn:aws:s3:::*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "velero" {
  user = aws_iam_user.velero.name
}

data "template_file" "velero_values" {
  template = file("${path.module}/templates/velero-values.yaml")

  vars = {
    access_key        = aws_iam_access_key.velero.id
    secret_access_key = aws_iam_access_key.velero.secret
    bucket_name       = "k8s-resource-backups"
    region            = var.app_region
  }
}

resource "helm_release" "velero" {
  name             = "velero"
  repository       = "https://vmware-tanzu.github.io/helm-charts/"
  chart            = "velero"
  version          = "7.1.5"
  namespace        = "velero"
  create_namespace = true
  depends_on       = [module.eks]

  values = [data.template_file.velero_values.rendered]
}

resource "time_sleep" "wait_for_velero" {
  depends_on      = [helm_release.velero]
  create_duration = "60s"
}

resource "kubectl_manifest" "velero_schedule" {
  yaml_body = yamlencode({
    apiVersion = "velero.io/v1"
    kind       = "Schedule"
    metadata = {
      name      = "${local.cluster_name}-daily-backup"
      namespace = "velero"
    }
    spec = {
      schedule = var.velero_schedule
      template = {
        excludedNamespaces = [
          "cert-manager",
          "db",
          "default",
          "kube-node-lease",
          "kube-public",
          "kube-system",
          "monitoring",
          "velero",
          "zop-system"
        ]
        ttl = "240h0m0s"
      }
    }
  })

  depends_on = [
    helm_release.velero,
    time_sleep.wait_for_velero
  ]
}