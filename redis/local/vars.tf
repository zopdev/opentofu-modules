variable "namespace" {
  description = "Namespace to which Redis instance is attached with"
  type        = string
  default     = ""
}

variable "min_cpu" {
  description = "CPU request for a container"
  type        = string
}

variable "max_cpu" {
  description = "CPU limit for a container"
  type        = string
}

variable "min_memory" {
  description = "Memory request for a container"
  type        = string
}

variable "max_memory" {
  description = "Memory limit for a container"
  type        = string
}

variable "storage_class" {
  description = "Persistent Volume storage class"
  type        = string
}

variable "disk_size" {
  description = "Persistent Volume size"
  type        = string
}