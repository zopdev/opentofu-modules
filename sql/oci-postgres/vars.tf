variable "subnet_id" {
  description = "Subnet id to host the PostgreSQL database"
  type        = string
}

variable "provider_id" {
  description = "OCI Compartment ID"
  type        = string
}

variable "postgres_shape_name" {
  description = "Shape of the PostgreSQL instance"
  type        = string
}

variable "availability_domain" {
  description = "Availability domain to install the PostgreSQL instance"
  type        = string
}

variable "administrator_login" {
  description = "The admin username for PostgreSQL database"
  type        = string
  default     = "postgresadmin"
}

variable "namespace" {
  description = "Namespace for the PostgreSQL service"
  type        = string
}

variable "vault_id" {
  description = "KMS vault id for vault secret"
  type        = string
}

variable "key_id" {
  description = "KMS key id for vault secret"
  type        = string
}

variable "postgres_db_system_name" {
  description = "Name of the PostgreSQL DB system"
  type        = string
}

variable "databases" {
  description = "Specifies the name of the PostgreSQL Database"
  type        = list(string)
  default     = []
}

variable "psql_version" {
  description = "Version of the postgres database"
  type        = number
  default     = 15
}

variable "iops" {
  description = "The storage IOPS for the Postgres Database system"
  type        = number
  default     = 75000
  validation {
    condition     = (var.iops >= 75000)
    error_message = "IOPS value must be greater than or equal to 75000."
  }
  validation {
    condition     = (var.iops <= 750000)
    error_message = "IOPS value must be less than or equal to 750000."
  }
}

variable "system_type" {
  description = "System type of the Postgres database"
  type        = string
  default     = "OCI_OPTIMIZED_STORAGE"
}

variable "instance_count" {
  description = "Count of the instance"
  type        = number
  default     = 1
}