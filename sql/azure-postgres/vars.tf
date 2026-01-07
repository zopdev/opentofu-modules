variable "resource_group_name" {
  description = "Azure resource group name for SQL server"
  type        = string
  default     = ""
}

variable "location" {
  description = "Azure location for SQL Server."
  type        = string
  default     = ""
}

variable "postgres_server_name" {
  description = "The name of the sql server"
  type        = string
  default     = ""
}

variable "administrator_login" {
  description = "The admin username for mysql database"
  type        = string
  default     = "psqladmin"
}

variable "administrator_password" {
  description = "The admin password for mysql database"
  type        = string
  default     = ""
}

variable "postgres_version" {
  description = "Version of the mysql database"
  type        = string
  default     = "13"
}

variable "collation" {
  description = "This is the collation type"
  type        = string
  default     = "en_US.utf8"
}

variable "charset" {
  description = "Specific character set encoding"
  type        = string
  default     = "utf8"
}

variable "sku_name" {
  description = "Indicates the type of virtual machine with vCPUs and memory"
  type        = string
  default     = "GP_Standard_D2s_v3"
}

variable "backup_retention_days" {
  description = "Backup retention days for the server"
  type        = number
  default     = 7
}

variable "databases" {
  description = "Specifies the name of the MySQL Database"
  type        = list(string)
  default     = []
}

variable "read_replica" {
  description = "To enable read replica for source mysql server"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for aws resources"
  type        = map(any)
}

variable "cluster_name" {
  description = "Name of the cluster to which MySQL instance is attached with"
  type        = string
  default     = ""
}

variable "namespace" {
  description = "Namespace to which MySQL instance is attached with"
  type        = string
  default     = ""
}

variable "key_vault_id" {
  type        = string
  default     = ""
}

variable "zone" {
  description = "zone for resources"
  type        = number
  default     = 2
}

variable "enable_ssl" {
  description = "Whether SSL should be enabled or not based on user requirement"
  type        = bool
  default     = false
}

variable "storage_mb" {
  description = "The amount of storage size in gb on SQL server"
  type        = number
  default     = 32768
  validation {
    condition = (var.storage_mb >= 32768 )
    error_message = "Storage value must be greater than or equal to 20."
  }
  validation {
    condition = (var.storage_mb <= 33553408 )
    error_message = "Storage value must be less than or equal to 16384."
  }
}

variable "storage_scaling" {
  description = "Boolean to enable auto grow on storage of the server"
  type        = bool
  default     = false
}

variable "storage_tier" {
  description = "Storage performance tier for IOPS of the PostgreSQL Flexible Server"
  type        = string
  default     = "P4"
}

variable "multi_ds" {
  description = "Whether to create multiple databases in the same instance"
  type        = bool
  default     = false
}

variable "vpc" {
  description = "VNet name the apps are going to use"
  type        = string
  default     = ""
}

variable "subnet" {
  description = "Subnet name the apps are going to use"
  type        = string
  default     = ""
}

variable "private_dns_zone_id" {
  description = "The ID of the private DNS zone for PostgreSQL Flexible Server"
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the PostgreSQL Flexible Server"
  type        = bool
  default     = true
}