variable "resource_group_name" {
  description = "The Azure Resource Group name in which all resources should be created."
  type        = string
  default     = ""
}

variable "vnet_config" {
  description = "VNet configuration - map of VNet names to their configuration"
  type = map(object({
    address_space         = list(string)
    private_subnets_cidr  = list(string)
    database_subnets_cidr = optional(list(string))
  }))
  default = {}
}
