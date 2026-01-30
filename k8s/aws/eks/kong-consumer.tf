#locals {
#  kong_consumer_list = try(flatten([
#  for ns in keys(var.kong_config.consumer_list) : [
#  for consumer in var.kong_config.consumer_list[ns] : {
#    name       = consumer.name
#    custom_id  = consumer.custom_id
#    group_list = try(consumer.group_list, [])
#    namespace  = ns
#  }
#  ]
#  ]), [])
#
#  kong_acl_list = try(flatten([
#  for ns in keys(var.kong_config.acl_allow_list) : [
#  for acl in var.kong_config.acl_allow_list[ns] : {
#    name       = acl.name
#    allow_list = try(acl.allow_list, [])
#    namespace  = ns
#  }
#  ]
#  ]), [])
#
#  kong_group_flatten_list = try([
#  for ns in keys(var.kong_config.consumer_list) : {
#    grouplist = toset(flatten([for consumer in var.kong_config.consumer_list[ns] : try(consumer.group_list, [])]))
#    namespace = ns
#  }
#  ], [])
#
#  kong_grp_list = try(flatten([
#  for item in local.kong_group_flatten_list : [
#  for grplist in item.grouplist : {
#    namespace  = item.namespace
#    group_name = grplist
#  }
#  ]
#  ]), [])
#
#
#}
###group
#resource "kubernetes_secret" "kong_acl_group" {
#  #for_each = [ for value in local.kong_grp_list : value ]
#  count = length(local.kong_grp_list)
#  metadata {
#    namespace = local.kong_grp_list[count.index].namespace
#    name      = local.kong_grp_list[count.index].group_name
#  }
#  type = "Opaque"
#  data = {
#    "kongCredType" = "acl"
#    "group"        = local.kong_grp_list[count.index].group_name
#  }
#}
#
#
#### consumer
#resource "random_password" "randomPassword" {
#  length   = 32
#  special  = false
#  for_each = {for k in local.kong_consumer_list : k.name => k}
#  lifecycle {
#    ignore_changes = [
#      length,
#      lower,
#      min_lower,
#      min_numeric,
#      min_special,
#      min_upper,
#      number,
#      result,
#      special,
#      upper,
#      id,
#      keepers
#    ]
#  }
#}
#
#resource "aws_secretsmanager_secret" "consumer_secrets" {
#  for_each = {for k in local.kong_consumer_list : k.name => k}
#  name     = "${local.cluster_name}-${each.value.name}-kong-consumer-secret"
#}
#
#resource "aws_secretsmanager_secret_version" "consumer_secret_value" {
#  for_each      = {for k in local.kong_consumer_list : k.name => k}
#  secret_id     = aws_secretsmanager_secret.consumer_secrets[each.key].id
#  secret_string = random_password.randomPassword[each.key].result
#}
#
#resource "kubernetes_secret" "consumer_cluster_secrets" {
#  for_each = {for k in local.kong_consumer_list : k.name => k}
#  metadata {
#    name = each.value.name
#  }
#  type = "Opaque"
#  data = {
#    "key"          = random_password.randomPassword[each.key].result
#    "kongCredType" = "key-auth"
#  }
#}
#
#data "template_file" "consumer_template" {
#  for_each = {for k in local.kong_consumer_list : k.name => k}
#  template = file("./templates/kong-consumer.yaml")
#  vars     = {
#    NAME        = each.value.name
#    SECRET_LIST = jsonencode(concat(each.value.group_list, [
#      kubernetes_secret.consumer_cluster_secrets[each.key].metadata.0.name
#    ]))
#    CUSTOM_ID = each.value.custom_id
#    NAMESPACE = each.value.namespace
#  }
#}
#
#resource "kubectl_manifest" "consumer" {
#  for_each   = {for k in local.kong_consumer_list : k.name => k}
#  yaml_body  = local.consumer_template[each.key]
#  depends_on = [kubernetes_secret.kong_acl_group]
#}
#
#
####acl
#data "template_file" "acl_template" {
#  for_each = {for k in local.kong_acl_list : k.name => k}
#  template = file("./templates/kong-acl.yaml")
#  vars     = {
#    NAME       = each.value.name
#    NAMESPACE  = each.value.namespace
#    ALLOW_LIST = jsonencode(each.value.allow_list)
#  }
#}
#
#resource "kubectl_manifest" "acl_allow_group" {
#  for_each   = {for k in local.kong_acl_list : k.name => k}
#  yaml_body  = local.acl_template[each.key]
#  depends_on = [kubectl_manifest.consumer]
#}
