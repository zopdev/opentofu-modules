locals {
  service_topic_pairs = flatten([
    for service_key, service in var.services : [
      for topic in service.topics : {
        service_key = service_key
        topic       = topic
      }
    ] if service.topics != null
  ])

  # Convert the list into a map
  flattened_service_topic_pairs = {
    for pair in local.service_topic_pairs :
    "${pair.service_key}-${pair.topic}" => pair
  }

  service_subscriptions_pairs = flatten([
    for service_key, service in var.services : [
      for subscriptions in service.subscriptions : {
        service_key = service_key
        subscriptions       = subscriptions
      }
    ] if service.subscriptions != null
  ])

  # Convert the list into a map
  flattened_service_subscriptions_pairs = {
    for pair in local.service_subscriptions_pairs :
    "${pair.service_key}-${pair.subscriptions}" => pair
  }

  cronjob_topic_pairs = flatten([
    for service_key, cronjob in var.cron_jobs : [
      for topic in cronjob.topics : {
        service_key = service_key
        topic       = topic
      }
    ] if cronjob.topics != null
  ])

  # Convert the list into a map
  flattened_cronjob_topic_pairs = {
    for pair in local.cronjob_topic_pairs :
    "${pair.service_key}-${pair.topic}" => pair
  }

  cronjob_subscriptions_pairs = flatten([
    for service_key, cronjob in var.cron_jobs : [
      for subscriptions in cronjob.subscriptions : {
        service_key = service_key
        subscriptions       = subscriptions
      }
    ]  if cronjob.subscriptions != null
  ])

  # Convert the list into a map
  flattened_cronjob_subscriptions_pairs = {
    for pair in local.cronjob_subscriptions_pairs :
    "${pair.service_key}-${pair.subscriptions}" => pair
  }

}


resource "google_service_account" "pubsub_editor" {
  for_each = { for k, v in var.services : k => v if coalesce(v.pub_sub,false) }
  account_id   = "pubsub-${random_string.service_account_name[each.key].result}"
  display_name = "Pub/Sub Service Account"
}

resource "google_pubsub_topic_iam_member" "pubsub_topic_editor" {
  for_each = { for k, v in local.flattened_service_topic_pairs : k => v }
  project = var.provider_id
  topic   = each.value.topic
  role    = "roles/pubsub.editor"
  member  = "serviceAccount:${google_service_account.pubsub_editor[each.value.service_key].email}"
}

# Grant permissions for each Pub/Sub subscription
resource "google_pubsub_subscription_iam_member" "pubsub_subscription_editor" {
  for_each = { for k, v in local.flattened_service_subscriptions_pairs : k => v }

  project        = var.provider_id
  subscription   = each.value.subscriptions
  role           = "roles/pubsub.editor"
  member         = "serviceAccount:${google_service_account.pubsub_editor[each.value.service_key].email}"
}

resource "google_service_account_key" "pubsub_editor_key" {
  for_each = { for k, v in var.services : k => v if coalesce(v.pub_sub,false) }
  service_account_id = google_service_account.pubsub_editor[each.key].name
}

resource "kubernetes_secret" "pubsub_credentials_gcp" {
  for_each = { for k, v in var.services : k => v if coalesce(v.pub_sub,false) }
  metadata {
    name = "pubsub-key-${random_string.service_account_name[each.key].result}"
    namespace = var.namespace
  }

  data = {
    "application_default_credentials.json" = base64decode(google_service_account_key.pubsub_editor_key[each.key].private_key)
  }
}

resource "google_service_account" "pubsub_editor_cron" {
  for_each = { for k, v in var.cron_jobs : k => v if coalesce(v.pub_sub,false) }
  account_id   = "pubsub-${random_string.service_account_name[each.key].result}"
  display_name = "Pub/Sub Service Account"
}

resource "google_pubsub_topic_iam_member" "pubsub_topic_editor_cron" {
  for_each = { for k, v in local.flattened_cronjob_topic_pairs : k => v }

  project = var.provider_id
  topic   = each.value.topic
  role    = "roles/pubsub.editor"
  member  = "serviceAccount:${google_service_account.pubsub_editor_cron[each.value.service_key].email}"
}

# Grant permissions for each Pub/Sub subscription
resource "google_pubsub_subscription_iam_member" "pubsub_subscription_editor_cron" {
  for_each = { for k, v in local.flattened_cronjob_subscriptions_pairs : k => v }

  project        = var.provider_id
  subscription   = each.value.subscriptions
  role           = "roles/pubsub.editor"
  member         = "serviceAccount:${google_service_account.pubsub_editor_cron[each.value.service_key].email}"
}


resource "google_project_iam_member" "service_pub_sub_admin" {
  for_each = { for k, v in var.services : k => v if var.pub_sub && v.pub_sub != null ? v.pub_sub : false}
  project  = var.provider_id
  role     = "roles/pubsub.admin"
  member   = "serviceAccount:${google_service_account.pubsub_editor[each.key].email}"
}

resource "google_project_iam_member" "cronjob_pub_sub_admin" {
  for_each = { for k, v in var.cron_jobs : k => v if var.pub_sub && v.pub_sub != null ? v.pub_sub : false}
  project  = var.provider_id
  role     = "roles/pubsub.admin"
  member   = "serviceAccount:${google_service_account.pubsub_editor_cron[each.key].email}"
}



resource "google_service_account_key" "pubsub_editor_cron_key" {
  for_each = { for k, v in var.cron_jobs : k => v if coalesce(v.pub_sub,false) }
  service_account_id = google_service_account.pubsub_editor_cron[each.key].name
}

resource "kubernetes_secret" "pubsub_credentials_cron_jobs_gcp" {
  for_each = { for k, v in var.cron_jobs : k => v if coalesce(v.pub_sub,false) }
  metadata {
    name = "pubsub-key-${random_string.service_account_name[each.key].result}"
    namespace = var.namespace
  }

  data = {
    "application_default_credentials.json" = base64decode(google_service_account_key.pubsub_editor_cron_key[each.key].private_key)
  }
}

