variable "service_secrets" {
  description = "Map of secret key-value pairs for the service"
  type        = map(string)
  default     = {}
}
