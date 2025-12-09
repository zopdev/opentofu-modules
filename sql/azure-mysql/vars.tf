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

variable "mysql_server_name" {
  description = "The name of the sql server"
  type        = string
  default     = ""
}

variable "administrator_login" {
  description = "The admin username for mysql database"
  type        = string
  default     = "mysqladmin"
}

variable "mysql_version" {
  description = "Version of the mysql database"
  type        = string
  default     = "5.7"
}

variable "collation" {
  description = "This is the collation type"
  type        = string
  default     = "utf8_unicode_ci"
}

variable "charset" {
  description = "Specific character set encoding"
  type        = string
  default     = "utf8"
}

variable "sku_name" {
  description = "Indicates the type of virtual machine with vCPUs and memory"
  type        = string
  default     = "GP_Standard_D2ds_v4"
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
  description = "Id of the azure key vault"
  type        = string
  default     = ""
}

variable "storage" {
  description = "The amount of storage size in gb on SQL server"
  type        = number
  default     = 20
  validation {
    condition     = (var.storage >= 20)
    error_message = "Storage value must be greater than or equal to 20."
  }
  validation {
    condition     = (var.storage <= 16384)
    error_message = "Storage value must be less than or equal to 16384."
  }
}

variable "storage_scaling" {
  description = "Boolean to enable auto grow on storage of the server"
  type        = bool
  default     = true
}

variable "iops" {
  description = "The storage IOPS for the MySQL Flexible Server"
  type        = number
  default     = 360
  validation {
    condition     = (var.iops >= 360)
    error_message = "IOPS value must be greater than or equal to 360."
  }
  validation {
    condition     = (var.iops <= 20000)
    error_message = "IOPS value must be less than or equal to 20000."
  }
}

variable "io_scaling_enabled" {
  description = "Boolean to scale IOPS.If true, iops can not be set"
  type        = bool
  default     = false
}

variable "multi_ds" {
  description = "Whether to create multiple databases in the same instance"
  type        = bool
  default     = false
}