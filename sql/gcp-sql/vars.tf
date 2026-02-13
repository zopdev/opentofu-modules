variable "project_id" {
  description = "The project ID to host the database."
  type        = string
  default     = ""
}

variable "project_number" {
  description = "The project number to provide the secret access role to fetch the secrets"
  type        = number
}

variable "region" {
  description = "The region to host the database."
  type        = string
  default     = ""
}

variable "app_uid" {
  description = "Random String of the Namespace"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of the cluster to which SQL instance is attached with"
  type        = string
  default     = ""
}

variable "namespace" {
  description = "Namespace to which SQL instance is attached with"
  type        = string
  default     = ""
}

variable "vpc_name" {
  description = "The vpc name for database"
  type        = string
  default     = ""
}

variable "machine_type" {
  description = "The machine type for the instances. See this page for supported tiers and pricing: https://cloud.google.com/sql/pricing"
  type        = string
  default     = "db-f1-micro"
}

variable "sql_name" {
  description = "Name of your sql instance"
  type        = string
  default     = ""
}

variable "sql_type" {
  description = "The RDS instance type(MySQL, PostgreSQL)"
  type        = string
  default     = ""
  validation {
    condition     = contains(["postgresql", "mysql", ""], var.sql_type)
    error_message = "Invalid rds_type. Valid values are [\"postgresql\",\"mysql\"]."
  }
}

variable "sql_version" {
  description = "RDS instance version"
  type        = string
  default     = ""
}

variable "databases" {
  description = "List of databases to be added in SQL instance"
  type        = list(string)
  default     = []
}

variable "activation_policy" {
  description = "This specifies when the instance should be active. Can be either `ALWAYS`, `NEVER` or `ON_DEMAND`."
  type        = string
  default     = "ALWAYS"
}

variable "authorized_networks" {
  description = "A list of authorized CIDR-formatted IP address ranges that can connect to this DB. Only applies to public IP instances."
  type        = list(map(string))
  default     = []

}

variable "availability_type" {
  description = "The availability type of the Cloud SQL instance, high availability (REGIONAL) or single zone (ZONAL)"
  type        = string
  default     = "ZONAL"
}

variable "disk_autoresize" {
  description = "Second Generation only. Configuration to increase storage size automatically."
  type        = bool
  default     = false
}

variable "disk_size" {
  description = "Second generation only. The size of data disk, in GB. Size of a running instance cannot be reduced but can be increased."
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "The type of storage to use. Must be one of `PD_SSD` or `PD_HDD`."
  type        = string
  default     = "PD_SSD"
}

variable "require_ssl" {
  description = "True if the instance should require SSL/TLS for users connecting over IP. Note: SSL/TLS is needed to provide security when you connect to Cloud SQL using IP addresses. If you are connecting to your instance only by using the Cloud SQL Proxy or the Java Socket Library, you do not need to configure your instance to use SSL/TLS."
  type        = bool
  default     = true
}

variable "private_network" {
  description = "The resource link for the VPC network from which the Cloud SQL instance is accessible for private IP."
  type        = string
  default     = null
}


variable "read_replica" {
  description = "whether sql read replica needs to be created or not "
  type        = bool
  default     = false
}

variable "num_read_replicas" {
  description = "The number of read replicas to create. Cloud SQL will replicate all data from the master to these replicas, which you can use to horizontally scale read traffic."
  type        = number
  default     = 0
}

variable "read_replica_zones" {
  description = "A list of compute zones where read replicas should be created. List size should match 'num_read_replicas'"
  type        = list(string)
  default     = []

  # Example:
  #  default = ["us-central1-b", "us-central1-c"]
}


variable "deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the instance. Unless this field is set to false in Terraform state, a terraform destroy or terraform apply command that deletes the instance will fail."
  type        = bool
  default     = true
}

variable "ext_rds_sg_cidr_block" {
  description = "additional/extra cidr blocks for the sql firewall group"
  type        = list(string)
  default     = []
}

variable "db_collation" {
  description = "Collation to be used while creating the DB"
  type        = string
  default = "en_US.UTF8"
}
  
variable "labels" {
  description = "Common Labels on the resources"
  type        = map(string)
}

variable "enable_ssl" {
  description = "Whether SSL should be enabled or not based on user requirement"
  type        = bool
  default     = true
}

variable "multi_ds" {
  description = "Whether to create multiple databases in the same instance"
  type        = bool
  default     = false
}