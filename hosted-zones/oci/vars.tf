variable "zones" {
  description = "The list of user access for the account setup"
  type = map(object({
    domain         = string
    add_ns_records = bool
  }))
}

variable "master_zone" {
  description = "Master zone for NS record to be added"
  type        = string
  default     = ""
}

variable "provider_id" {
  description = "OCI compartment ID"
  type        = string
}