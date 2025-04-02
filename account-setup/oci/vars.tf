variable "subnets" {
  type = map(
    object(
      {
        vpc_cidr              = string
        public_subnets_cidr   = list(string)
        private_subnets_cidr  = list(string)
        db_subnets_cidr       = list(string)
      }
    )
  )
  description = "CIDR block for VCNs and subnets"
  default     = {}
}

variable "provider_id" {
  description = "Compartment ID"
  type        = string
  default     = ""
}