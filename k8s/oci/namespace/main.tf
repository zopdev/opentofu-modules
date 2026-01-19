locals {

  service_oar_name_map = {
    for key, config in var.services : key => coalesce(config.oar_name, key)
  }

  cronjob_oar_name_map = {
    for key, config in var.cron_jobs : key => coalesce(config.oar_name, key)
  }
  
  oar_name_map = merge(local.service_oar_name_map, local.cronjob_oar_name_map)

  artifact_users_map = {
    for user in data.oci_identity_users.all_users.users :
    user.email => user.id
  }

  artifact_users = [
    for email in var.artifact_users :
    lookup(local.artifact_users_map, email, null)
    if lookup(local.artifact_users_map, email, null) != null
  ]

  common_tags        = merge(var.common_tags,
    tomap({
      "zop.project"     = try(var.standard_tags.project != null ? var.standard_tags.project : local.cluster_name ,local.cluster_name)
      "zop.provisioner" = try(var.standard_tags.provisioner != null ? var.standard_tags.provisioner : "zop-dev", "zop-dev")
    }))
}

data "oci_identity_users" "all_users" {
  compartment_id = var.provider_id
}

resource "kubernetes_namespace" "app_environments" {

  metadata {
    name = var.namespace
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "oci_identity_dynamic_group" "artifact_users_group" {
  count          = length(local.artifact_users) > 0 ? 1 : 0

  name           = "artifact-users-group"
  description    = "Dynamic group for artifact registry users"
  compartment_id = var.provider_id

  matching_rule = join(" OR ", [
    for user_id in local.artifact_users :
    "ALL {resource.id = '${user_id}'}"
  ])
}

data "oci_identity_compartment" "current" {
  id = var.provider_id
}

resource "oci_identity_policy" "artifact_access_policy" {
  count          = length(local.artifact_users) > 0 ? 1 : 0

  name           = "artifact-access-policy"
  description    = "Allows access to artifact registries for dynamic group"
  compartment_id = data.oci_identity_compartment.current.id
  
  statements = ["Allow dynamic-group ${oci_identity_dynamic_group.artifact_users_group[0].name} to manage repos in compartment id ${data.oci_identity_compartment.current.id}"]
}