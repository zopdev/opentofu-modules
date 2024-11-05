variable "pubsub_topic_config" {
  description = "List of Pub/Sub topics"
  type = list(object({
    topic_name                     = string
    message_storage_policy         = optional(object({
      allowed_persistence_regions = list(string)
    }))
    schema_settings = optional(object({
      encoding = optional(string)
      schema   = string
    }))
    topic_message_retention_duration = optional(string)
  }))
  default = []
}

variable "pubsub_subscription_config" {
  description = "List of Pub/Sub subscriptions"
  type = list(object({
    topic_name                 = string
    subscription_name          = string
    ack_deadline_seconds       = optional(number)
    message_retention_duration = optional(string)
    retain_acked_messages      = optional(bool)
    expiration_policy          = optional(object({
      ttl = string
    }))
    push_config = optional(object({
      push_endpoint = string
      attributes    = optional(map(string))
      oidc_token    = optional(object({
        service_account_email = string
        audience              = optional(string)
      }))
    }))
  }))
  default = []
}

variable "pubsub_schema_config" {
  description = "List of Pub/Sub schemas"
  type = list(object({
    name       = string
    type       = optional(string)
    definition = optional(string)
    project    = optional(string)
  }))
  default = []
}

variable "project" {
  description = "Project ID"
  type = string
}