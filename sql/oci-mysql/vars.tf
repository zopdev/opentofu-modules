variable "subnet_id" {
  description = "Subnet id to host the mysql database"
  type        = string
}

variable "provider_id" {
  description = "OCI Compartment ID"
  type        = string
}

variable "mysql_shape_name" {
  description = "Shape of the mysql instance"
  type        = string
}

variable "availability_domain" {
  description = "Availability domain to install the mysql instance"
  type        = string
}

variable "administrator_login" {
  description = "The admin username for mysql database"
  type        = string
  default     = "mysqladmin"
}

variable "namespace" {
  description = "Namespace for the mysql service"
  type        = string
}

variable "vault_id" {
  description = "Kms vault id for vault secret"
  type        = string
}

variable "key_id" {
  description = "Kms key id for vault secret"
  type        = string
}

variable "mysql_db_system_name" {
  description = "Name of the Mysql db system"
  type        = string
}

variable "storage" {
  description = "The amount of storage size in GB on SQL server"
  type        = number
  default     = 50

  validation {
    condition     = var.storage >= 50
    error_message = "The storage size must be greater than or equal to 50 GB."
  }
}

variable "storage_scaling" {
  description = "Boolean to enable auto grow on storage of the server"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "If the DB instance  has deletion protection enabled ,  then database can't be deleted when this value is set to true"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Backup retention days for the server"
  type        = number
  default     = 7
}

variable "read_replica" {
  description = "Whether to enable the read replica"
  type        = bool
  default     = false
}

variable "databases" {
  description = "Specifies the name of the MySQL Database"
  type        = list(string)
  default     = []
}

variable "enable_ssl" {
  description = "Whether SSL should be enabled or not based on user requirement"
  type        = bool
  default     = false
}