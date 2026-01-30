locals {
  issuer_yaml = templatefile("${path.module}/templates/issuer.yaml", {
    namespace       = kubernetes_namespace.app_environments.metadata[0].name
    email           = var.cert_issuer_config.email
    cert_issuer_url = try(
        var.cert_issuer_config.env == "stage" ?
        "https://acme-staging-v02.api.letsencrypt.org/directory" :
        "https://acme-v02.api.letsencrypt.org/directory",
      "https://acme-staging-v02.api.letsencrypt.org/directory"
    )
  })
}


resource "kubectl_manifest" "namespace_issuer" {
  yaml_body = local.issuer_yaml
}

resource "kubernetes_secret_v1" "namespace-cert-replicator" {
  metadata {
    name = "tls-secret-replica"
    namespace = kubernetes_namespace.app_environments.metadata[0].name
    annotations = {
      "replicator.v1.mittwald.de/replicate-from" = "cert-manager/wildcard-dns"
    }
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.key" = ""
    "tls.crt" = ""
  }
  lifecycle {
    ignore_changes = all
  }
}