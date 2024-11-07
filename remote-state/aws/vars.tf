variable "bucket_name" {
  description = "s3 bucket"
  type        = string
}

variable "bucket_prefix" {
  description = "path for terraform state file of resource"
  type        = string
}

variable "provider_id" {
  description = "profile name"
  type        = string
}

variable "location" {
  description = "location"
  type        = string
}