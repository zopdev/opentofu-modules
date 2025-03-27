variable "services" {
  description = "List of services to be deployed within the namespace"
  type        = list(string)
  default     = []
}

variable "provider_id" {
  description = "Compartment ID"
  type        = string
  default     = ""
}