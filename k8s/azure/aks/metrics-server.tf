#locals {
#  metrics_server_yaml = split("---", file("./templates/metrics-server.yaml"))
#}
#
#resource "kubectl_manifest" "metrics_server" {
#  for_each  = { for key, id in local.metrics_server_yaml : key => id }
#  yaml_body = each.value
#}