variable "resource_group_name" {
  description = "The Azure Resource Group name in which all resources should be created."
  type        = string
  default     = ""
}

variable "vnet" {
  description = "Name of the virtual network where the AKS will deploy"
  type        = string
  default     = ""
}

variable "address_space" {
  description = "The address space that is used the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}