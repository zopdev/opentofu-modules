# GCP Pub/Sub Module 

This Terraform module provisions and manages Google Cloud Pub/Sub topics, subscriptions, and schemas, offering configurable options for message retention, acknowledgment deadlines, and schema validations.

## Variables

| Key                            | Type              | Required/Optional | Description                                                                       | Default |
|--------------------------------|-------------------|-------------------|-----------------------------------------------------------------------------------|---------|
| project                        | string            | Required          | Project ID.                                                                        |         |
| pubsub_topic_config            | list(object)      | Required          | List of Pub/Sub topics.                                                           | `[]`    |
| pubsub_subscription_config     | list(object)      | Required          | List of Pub/Sub subscriptions.                                                    | `[]`    |
| pubsub_schema_config           | list(object)      | Required          | List of Pub/Sub schemas.                                                          | `[]`    |

### Pub/Sub Topic Configuration

| Key                                    | Type              | Required/Optional | Description                                                                       | Default        |
|----------------------------------------|-------------------|-------------------|-----------------------------------------------------------------------------------|----------------|
| topic_name                             | string            | Required          | Name of the Pub/Sub topic.                                                        |                |
| message_storage_policy                 | object            | Optional          | Message storage policy for the topic.                                             | `{}`           |
| message_storage_policy.allowed_persistence_regions | list(string) | Optional          | List of allowed persistence regions for the message storage policy.              | `[]`           |
| schema_settings                        | object            | Optional          | Schema settings for the topic.                                                    | `{}`           |
| schema_settings.encoding               | string            | Optional          | Encoding for the schema.                                                          | `JSON`         |
| schema_settings.schema                 | string            | Required          | The schema definition.                                                            |                |
| topic_message_retention_duration       | string            | Optional          | Message retention duration for the topic.                                         | `604800s`      |

### Pub/Sub Subscription Configuration

| Key                            | Type              | Required/Optional | Description                                                                       | Default        |
|--------------------------------|-------------------|-------------------|-----------------------------------------------------------------------------------|----------------|
| topic_name                     | string            | Required          | Name of the Pub/Sub topic associated with the subscription.                       |                |
| subscription_name              | string            | Required          | Name of the Pub/Sub subscription.                                                 |                |
| ack_deadline_seconds           | number            | Optional          | Acknowledgment deadline for the subscription.                                     | `10`           |
| message_retention_duration     | string            | Optional          | The duration for which messages are retained.                                     | `604800s`      |
| retain_acked_messages          | bool              | Optional          | Whether to retain acknowledged messages.                                          | `false`        |
| expiration_policy              | object            | Optional          | Expiration policy for the subscription.                                           | `{}`           |
| expiration_policy.ttl          | string            | Optional          | TTL for the expiration policy.                                                    |                |
| push_config                    | object            | Optional          | Push configuration for the subscription.                                          | `{}`           |
| push_config.push_endpoint      | string            | Optional          | Endpoint to which messages should be pushed.                                      |                |
| push_config.attributes         | map(string)       | Optional          | Attributes for the push configuration.                                            | `{}`           |
| push_config.oidc_token         | object            | Optional          | OIDC token configuration for push endpoints.                                      | `{}`           |
| push_config.oidc_token.service_account_email | string | Optional       | Service account email for OIDC token.                                             |                |
| push_config.oidc_token.audience | string            | Optional          | Audience for the OIDC token.                                                      |                |

### Pub/Sub Schema Configuration

| Key                            | Type              | Required/Optional | Description                                                                       | Default        |
|--------------------------------|-------------------|-------------------|-----------------------------------------------------------------------------------|----------------|
| name                           | string            | Required          | Name of the Pub/Sub schema.                                                       |                |
| type                           | string            | Optional          | Type of the schema.                                                               | `AVRO`         |
| definition                     | string            | Optional          | Definition of the schema.                                                         | `"{\n  \"type\" : \"record\",\n  \"name\" : \"Avro\",\n  \"fields\" : [\n    {\n      \"name\" : \"StringField\",\n      \"type\" : \"string\"\n    },\n    {\n      \"name\" : \"IntField\",\n      \"type\" : \"int\"\n    }\n  ]\n}\n"` |
| project                        | string            | Optional          | Project ID for the schema.                                                        | `var.project`  |