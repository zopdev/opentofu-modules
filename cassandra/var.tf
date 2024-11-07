variable "name" {
  description = "Name for cassandra database"
  type        = string
}

variable "admin_user" {
  description = "Username for cassandra "
  type        = string
}

variable "replica_count" {
  description = "Number of Cassandra replicas"
  type        = number
  default     = 1
}

variable "persistence_size" {
  description = "PVC Storage Request for Cassandra data volume"
  type        = number
  default     = 10
}

variable "cassandra_password" {
  description = "Password for cassandra"
  type        = string
}