variable "subnets" {
  type        = map(
    object(
      {
        vpc_cidr              = string
        public_subnets_cidr   = list(string)
        private_subnets_cidr  = list(string)
        db_subnets_cidr       = list(string)
        availability_zones    = list(string)
      }
    )
  )
  description = "CIDR block for subnets"
  default     = {}
}