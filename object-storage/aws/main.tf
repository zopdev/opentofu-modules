resource "aws_s3_bucket" "this" {
  for_each      = toset(var.bucket_names)
  bucket        = each.key
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}