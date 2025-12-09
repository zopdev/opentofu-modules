
variable "app_name" {
  description = "AppDynamics Controller URL."
  type        = string
}

variable "lb_ip" {
  description = "Global IP address to be added in LoadBalancer"
  type        = string
}

variable "prometheus_enabled" {
  description = "Enable the creation of prometheus based on user input"
  type        = string
}