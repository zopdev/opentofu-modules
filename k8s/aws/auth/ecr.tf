locals {
  ecr_arns = [
    for config in var.ecr_configs :
    "arn:aws:ecr:${config.region}:${config.account_id}:repository/${config.name}"
  ]

  ecr_editors = distinct(concat(var.masters,var.editors,var.system_authenticated_admins,var.system_authenticated_editors))
  ecr_viewers = distinct(concat(var.viewers,var.system_authenticated_viewers))

  ecr_editor_map = { for key in local.ecr_editors : key => key }
  ecr_viewer_map = { for key in local.ecr_viewers : key => key }
}
# ECR Editor Policy

resource "random_string" "ecr_policy_suffix" {
  length = 6
  special = false
}

resource "aws_iam_policy" "ecr_editor_policy" {
  name        = "${local.cluster_name}-ecr-editor-policy-${random_string.ecr_policy_suffix.result}"
  description = "Allows limited access to ECR resources for pushing and pulling images"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid     = "ECREditorAccess",
        Effect  = "Allow",
        Action  = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchGetImage" # Additional permissions required for pulling images
        ],
        Resource = local.ecr_arns
      }
    ]
  })
}

# ECR Viewer Policy
resource "aws_iam_policy" "ecr_viewer_policy" {
  name        = "${local.cluster_name}-ecr-viewer-policy-${random_string.ecr_policy_suffix.result}"
  description = "Allows read-only access to ECR resources"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid     = "ECRViewerAccess",
        Effect  = "Allow",
        Action  = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage" # Permissions only for pulling images
        ],
        Resource = local.ecr_arns
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "ecr_editor_policy_attachment" {
  for_each = local.ecr_editor_map
  user = each.value
  policy_arn = aws_iam_policy.ecr_editor_policy.arn
}

resource "aws_iam_user_policy_attachment" "ecr_viewer_policy_attachment" {
  for_each = local.ecr_viewer_map
  user = each.value
  policy_arn = aws_iam_policy.ecr_viewer_policy.arn
}