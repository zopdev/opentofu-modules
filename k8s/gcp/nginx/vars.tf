variable "project" {
  description = "Project ID where the resources to be created"
  type        = string
}

variable "app_region" {
  description = "Load balancer nginx region"
  type        = string
  default     = ""
}

variable "node_port" {
  description = "Node Port on which to expose kong."
  type        = number
}

variable "app_env" {
  description = "This is Environment where the NLB is deployed."
  type        = string
}

variable "app_name" {
    description = "AppDynamics Controller URL."
    type        = string
}

variable "lb_ip" {
  description = "Global IP address to be added in LoadBalancer"
  type   = string
}

variable "prometheus_enabled" {
  description = "Enable the creation of prometheus based on user input"
  type        = string
}