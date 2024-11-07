variable "node_port" {
  description = "Node Port on which to expose kong."
  type        = number
}

variable app_name {
  type = string
  description = "Name of AKS cluster"
  default = ""
}

variable "node_resource_group" {
  description = "Node Port on which to expose kong."
  type        = string
}

variable "lb_ip" {
  description = "Static IP address to attach to loadbalancer"
  type = string
}

variable "prometheus_enabled" {
  description = "Enable the creation of prometheus based on user input"
  type        = string
}