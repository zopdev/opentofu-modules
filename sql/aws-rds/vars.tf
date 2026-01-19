variable "ext_rds_sg_cidr_block" {
  description = "additional/extra cidr blocks for the rds security group"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "The vpc id for the cluster"
  type        = string
  default     = ""
}

variable "db_subnets" {
  description = "The private vpc subnets for the cluster"
  type        = list(string)
  default     = []
}

variable "aws_region" {
  description = "The AWS region to deploy to (e.g. us-east-1)"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of the cluster to which RDS instance is attached with"
  type        = string
  default     = ""
}

variable "namespace" {
  description = "Namespace to which RDS instance is attached with"
  type        = string
  default     = ""
}

variable "rds_name" {
  description = "The Name of RDS Resource"
  type        = string
  default     = ""
}

variable "databases" {
  description = "List of databases to be added in RDS instance"
  type        = list(string)
  default     = []
}

variable "admin_user" {
  description = "The Admin username for rds"
  type        = string
  default     = ""
}

variable "instance_class" {
  description = "The type of RDS Instnaces to run in the ASG (e.g. db.t3.micro)"
  type        = string
  default     = ""
}

variable "rds_type" {
  description = "The RDS instance type(MySQL, PostgreSQL)"
  type        = string
  default     = ""
  validation {
    condition     = contains(["postgresql", "mysql", ""], var.rds_type)
    error_message = "Invalid rds_type. Valid values are [\"postgresql\",\"mysql\"]."
  }
}

variable "allocated_storage" {
  description = "The amount of storage for rds"
  type        = number
  default     = 0
}

variable "tags" {
  description = "Tags for aws resources"
  type        = map(any)
}

variable "multi_az" {
  description = "Option to enable multi availability zone"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "If the DB instance  has deletion protection enabled ,  then database can't be deleted when this value is set to true"
  type        = bool
  default     = true
}

variable "max_allocated_storage" {
  description = "When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Must be greater than or equal to allocated_storage,0 to disable Storage Autoscaling."
  type        = number
  default     = 0
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 5. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  default     = 0
  type        = number
}

variable "log_min_duration_statement" {
  description = "Sets the minimum execution time above which all statements will be logged."
  type        = number
  default     = -1
  validation {
    condition     = (var.log_min_duration_statement > 0 || var.log_min_duration_statement == -1)
    error_message = "To disable slow query logs, specify -1. The default is -1. Valid values are any positive integer."
  }
}

variable "read_replica" {
  description = "whether rds read replica needs to be created or not"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "whether to apply changes immediately or not"
  type        = bool
  default     = false
}

variable "storage_tier" {
  description = "The storage type of the rds instance"
  type        = string
  default     = "gp3"
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
  type        = bool
  default     = false
}


variable "postgresql_engine_version" {
  description = "The engine version to use for postgresql"
  type        = string
  default     = "16.1"
}

variable "read_replica_multi_az" {
  description = "Option to enable multi availability zone for RDS read replica"
  type        = bool
  default     = false
}

variable "mysql_engine_version" {
  description = "the engine version for mysql"
  type        = string
  default     = "8.0"
}

variable "enable_ssl" {
  description = "Whether SSL should be enabled or not based on user requirement"
  type        = bool
  default     = false
}

variable "multi_ds" {
  description = "Whether to create multiple databases in the same instance"
  type        = bool
  default     = false
}