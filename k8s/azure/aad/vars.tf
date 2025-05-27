variable "users" {
  description = "List of User principal names to be added to AAD"
  type        = list(string)
  default     = []
}
variable "service_secrets" {
  description = "Map of secret key-value pairs for the service"
  type        = map(string)
  default     = {}
}
