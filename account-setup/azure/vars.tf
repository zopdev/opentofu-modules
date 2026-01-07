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

variable "create_nat_gateway" {
  description = "Whether to create NAT Gateway for private subnet outbound connectivity"
  type        = bool
  default     = false
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet (for NAT Gateway)"
  type        = list(string)
  default     = ["10.0.0.0/24"]
}

variable "create_private_subnet" {
  description = "Whether to create private subnet for AKS nodes and services"
  type        = bool
  default     = false
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet (for AKS nodes and services)"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "create_database_subnet" {
  description = "Whether to create subnet for databases (MySQL, PostgreSQL)"
  type        = bool
  default     = false
}

variable "database_subnet_cidr" {
  description = "CIDR block for database subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}
