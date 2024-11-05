terraform {
  backend "gcs" {}
}

resource "google_pubsub_schema" "pubsub_schema" {
  for_each = { for schema in var.pubsub_schema_config : schema.name => schema }

  name       = each.value.name
  type       = each.value.type != null ? each.value.type : "AVRO"
  definition = each.value.definition != null ? each.value.definition : "{\n  \"type\" : \"record\",\n  \"name\" : \"Avro\",\n  \"fields\" : [\n    {\n      \"name\" : \"StringField\",\n      \"type\" : \"string\"\n    },\n    {\n      \"name\" : \"IntField\",\n      \"type\" : \"int\"\n    }\n  ]\n}\n"
  project    = each.value.project != null ? each.value.project : var.project

}

resource "google_pubsub_topic" "pubsub_topic" {
  for_each = { for topic in var.pubsub_topic_config : topic.topic_name => topic }
  name     = each.key

  message_retention_duration = each.value.topic_message_retention_duration != null ? each.value.topic_message_retention_duration : "604800s"

  dynamic "message_storage_policy" {
    for_each = each.value.message_storage_policy != null ? [each.value.message_storage_policy] : []
    content {
      allowed_persistence_regions = message_storage_policy.value.allowed_persistence_regions
    }
  }
  dynamic "schema_settings" {
    for_each = each.value.schema_settings != null ? [each.value.schema_settings] : []
    content {
      schema   = "projects/${var.project}/schemas/${schema_settings.value.schema}"
      encoding = schema_settings.value.encoding != null ? schema_settings.value.encoding : "JSON"
    }
  }
  depends_on = [google_pubsub_schema.pubsub_schema]
}

resource "google_pubsub_subscription" "pubsub_subscription" {
  for_each = { for sub in var.pubsub_subscription_config : sub.subscription_name => sub }

  name  = each.key
  topic = google_pubsub_topic.pubsub_topic[each.value.topic_name].name

  ack_deadline_seconds       = each.value.ack_deadline_seconds != null ? each.value.ack_deadline_seconds : 10  
  message_retention_duration = each.value.message_retention_duration != null ? each.value.message_retention_duration : "604800s"  
  retain_acked_messages      = each.value.retain_acked_messages != null ? each.value.retain_acked_messages : false 

  dynamic "expiration_policy" {
    for_each = each.value.expiration_policy != null ? [each.value.expiration_policy] : []
    content {
      ttl = expiration_policy.value.ttl
    }
  }

  dynamic "push_config" {
    for_each = each.value.push_config != null ? [each.value.push_config] : []
    content {
      push_endpoint = push_config.value.push_endpoint
      attributes    = push_config.value.attributes != null ? push_config.value.attributes : {}  

      dynamic "oidc_token" {
        for_each = push_config.value.oidc_token != null ? [push_config.value.oidc_token] : []
        content {
          service_account_email = oidc_token.value.service_account_email
          audience              = oidc_token.value.audience != null ? oidc_token.value.audience : ""  
        }
      }
    }
  }
}
