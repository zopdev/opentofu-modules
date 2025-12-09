variable "kafka_broker_nodes" {
  description = "The desired total number of broker nodes in the kafka cluster. It must be a multiple of the number of specified client subnets."
  type        = number
  default     = 0
}

variable "kafka_size" {
  description = "The size in GiB of the EBS volume for the data drive on each broker node."
  type        = number
  default     = 10
}

variable "kafka_broker_instance" {
  description = "Specify the instance type to use for the kafka brokers."
  type        = string
  default     = "kafka.t3.small"
}

variable "kafka_cluster_name" {
  description = "eks cluster name"
  type        = string
}

variable "kafka_subnets" {
  description = "A list of subnets to connect to in client VPC"
  type        = list(string)
}

variable "kafka_admin_user" {
  description = "admin user for msk cluster"
  type        = string
}

variable "common_tags" {
  description = "additional tags for merging with common tags"
  type        = map(string)
  default     = {}
}

