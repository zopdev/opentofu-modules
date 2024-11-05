variable "users" {
  description = "List of User principal names to be added to AAD"
  type        = list(string)
  default     = []
}
