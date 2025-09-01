locals {
  calert_template = split("---", file("./templates/calert.yaml"))
}

resource "kubectl_manifest" "calert_config" {
  count = local.google_chat_alerts == {} ? 0 : 1
  yaml_body = templatefile("${path.module}/templates/calert.yaml", {
    GOOGLE_CHAT_ENDPOINT_URL = jsonencode(local.google_chat_alerts)
  })
}

resource "kubectl_manifest" "calert" {
  count     = local.google_chat_alerts == {} ? 0 : 2
  yaml_body = local.calert_template[count.index + 1]
}
