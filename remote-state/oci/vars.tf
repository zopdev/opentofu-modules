variable "bucket_name" {
  description = "name of the bucket"
  type        = string
}

variable "bucket_prefix" {
  description = "prefix for resource terraform state file"
  type = string
}