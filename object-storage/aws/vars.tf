variable "bucket_names" {
  description = "List of S3 bucket names to create"
  type        = list(string)
  default     = []
}

variable "enable_versioning" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = false
}

