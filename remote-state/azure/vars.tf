variable "bucket_prefix" {
  description = "Prefix of the storage container blob."
  type        = string
}

variable "resource_group" {
  description = "The Azure Resource Group name in which all resources should be created."
  type        = string
}

variable "storage_account" {
  description = "Name of the storage account"
  type = string
}

variable "container" {
  description = "Name of the container which store tfstate files"
  type = string
}

variable "client_id" {
  description = "The Client ID for the Service Principal used to authenticate with Azure"
  type        = string
  default     = null
}

variable "client_secret" {
  description = "The Client Secret for the Service Principal used to authenticate with Azure"
  type        = string
  default     = null
  sensitive   = true
}

variable "tenant_id" {
  description = "The Tenant ID for the Service Principal used to authenticate with Azure"
  type        = string
  default     = null
}

variable "subscription_id" {
  description = "The Subscription ID for the Service Principal used to authenticate with Azure"
  type        = string
  default     = null
}