variable "app_name" {
  description = "This is the name for the NLB."
  type        = string
}

variable "app_env" {
  description = "This is Environment where the NLB is deployed."
  type        = string
}

variable "common_tags" {
  description = "A map of common tags for the resources"
  type        = map(string)
  default     = {}
}

variable "inbound_ip" {
  description = "list of ip range that are allowed access to services on EKS cluster"
  type        = list
  default     = ["10.0.0.0/8"]
}

variable "public_app" {
  description = "whether application deploy on public ALB"
  type        = bool
  default     = false
}

variable "provisioner" {
  description = "Provisioner being used to setup Infra"
  type        = string
  default     = "zop-dev"
}