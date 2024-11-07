variable "resource_group_name" {
  description = "Resource group where the resources exists"
  type        = string
}

variable "cluster_name" {
  description = "Name of the cluster on which kube-management-api should be deployed"
  type        = string
}

variable "app_region" {
  description = "App region of the cluster"
  type        = string
}

variable "host" {
  description = "Domain to be used for kube-management-api"
  type        = string
}