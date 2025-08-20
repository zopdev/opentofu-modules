variable "users" {
  description = "List of User principal names to be added to AAD"
  type        = list(string)
  default     = []
}

variable "provisioner" {
  description = "Provisioner being used to setup Infra"
  type        = string
  default     = "zop-dev"
}
