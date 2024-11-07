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