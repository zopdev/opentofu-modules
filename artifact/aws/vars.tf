
variable "services" {
  description = "List of services to be deployed within the namespace"
  type        = list(string)
  default     = []
}

variable "immutable_image_tags" {
  description = "Specifies the ECR image tags are immutable"
  type        = bool
  default     = true
}