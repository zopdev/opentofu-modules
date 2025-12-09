
variable "load_balancer_shape" {
  description = "The shape of the load balancer"
  type        = string
  default     = "flexible"
}

variable "lb_subnet_id" {
  description = "The subnet OCID where the load balancer will be deployed"
  type        = string
}

variable "app_name" {
  description = "This is the name for the project. This name is also used to namespace all the other resources created by this module."
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