
variable "services" {
  description = "List of services to be deployed within the namespace"
  type        = list(string)
  default     = []
}

variable "provisioner" {
  description = "Provisioner being used to setup Infra"
  type        = string
  default     = "zop-dev"
}