variable "cluster_name" {
  description = "Name of the cluster on which kops-kube should be deployed"
  type        = string
}

variable "provider_id" {
  description = "ID of the GCP project"
  type        = string
}

variable "app_region" {
  description = "App region of the cluster"
  type        = string
}

variable "host" {
  description = "Domain to be used for kops-kube"
  type        = string
}

variable "bucket_name" {
  description = "Name of the bucket remote state bucket"
  type        = string
}

variable "cluster_prefix" {
  description = "prefix for cluster terraform state file"
  type = string
  default = ""
}