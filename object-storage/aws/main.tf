resource "aws_s3_bucket" "s3_bucket" {
  for_each      = toset(var.bucket_names)
  bucket        = each.key
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "s3_versioning" {
  for_each = aws_s3_bucket.s3_bucket

  bucket = each.value.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_kms_encryption" {
  for_each = aws_s3_bucket.s3_bucket

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}