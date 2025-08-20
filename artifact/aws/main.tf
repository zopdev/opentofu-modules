resource "aws_ecr_repository" "ecr_repo" {
  for_each = toset(var.services)
  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = each.value
    Provisioner = var.provisioner
  }
}