resource "aws_ecr_repository" "ecr_repo" {
  for_each = toset(var.services)

  name = each.value

  image_tag_mutability = var.immutable_image_tags ? "IMMUTABLE" : "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}