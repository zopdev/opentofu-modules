variable "provider_id" {
  description = "Project ID"
  type        = string
  default     = ""
}

variable "app_region" {
  description = "Region for creating the network configurations"
  type        = string
  default     = ""
}

variable "vpc_config" {
  description = "VPC configuration in Project"
  type        = map(object( {
    private_subnets_cidr = list(string)
  }
  ))
}