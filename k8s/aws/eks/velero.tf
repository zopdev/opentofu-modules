resource "aws_s3_bucket" "velero" {
  bucket = "${local.cluster_name}-velero-backups"
  force_destroy = true

  tags = merge(local.common_tags, {
    "Name" = "velero-backup-bucket"
  })
}

resource "aws_iam_user" "velero" {
  name = "${local.cluster_name}-velero-user"
  tags = local.common_tags
}

resource "aws_iam_user_policy" "velero" {
  name = "velero-policy"
  user = aws_iam_user.velero.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
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
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ],
        Resource = [
          "arn:aws:s3:::${module.s3_bucket.s3_bucket_id}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = ["arn:aws:s3:::${module.s3_bucket.s3_bucket_id}"]
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
    bucket_name       = module.s3_bucket.s3_bucket_id
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
