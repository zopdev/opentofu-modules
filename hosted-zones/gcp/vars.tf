variable "zones" {
  description = "The list of user access for the account setup"
  type = map(object({
    domain = string
    add_ns_records = bool
  }))
}

variable "user_access" {
  description = "map of roles for domain"
  type = object({
    editors = optional(list(string))
    viewers = optional(list(string))
  })
  default = {}
}

variable "provisioner" {
  description = "Provisioner being used to setup Infra"
  type        = string
  default     = "zop-dev"
}

variable "master_zone" {
  description = "master zone for ns record to be added"
  type = string
  default = ""
}

variable "provider_id" {
  description = "gcp project id"
  type = string
}

variable "caa_certs" {
  type        = list(string)
  description = "The caa records to prevent cert issue"
  default     = []
}