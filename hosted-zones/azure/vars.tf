variable "zones" {
  description = "The list of user access for the account setup"
  type = map(object({
    domain         = string
    add_ns_records = bool
  }))
}

variable "master_zone" {
  description = "master zone for ns record to be added"
  type        = string
  default     = ""
}

variable "resource_group_name" {
  description = "azure resource group name"
  type        = string
}

variable "caa_certs" {
  type        = list(string)
  description = "The caa records to prevent cert issue"
  default     = []
}