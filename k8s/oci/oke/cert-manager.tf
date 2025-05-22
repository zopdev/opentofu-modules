locals {
  private_key_content = <<EOF
  ${var.private_key_content}
  EOF
}

resource "oci_identity_dynamic_group" "cert_manager_group" {
  compartment_id = var.provider_id
  name           = "${local.cluster_name}-cert-manager-dg"
  description    = "Dynamic group for Cert Manager in ${local.cluster_name} OKE cluster"
  matching_rule  = "ALL {instance.compartment.id = '${var.provider_id}'}"
}

resource "oci_identity_policy" "cert_manager_policy" {
  compartment_id = var.provider_id
  name           = "${local.cluster_name}-cert-manager-policy"
  description    = "Policy for Cert Manager in ${local.cluster_name} OKE cluster"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.cert_manager_group.name} to manage dns-zone in compartment id ${var.provider_id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.cert_manager_group.name} to manage certificate-authority-family in compartment id ${var.provider_id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.cert_manager_group.name} to manage dns-records in compartment id ${var.provider_id}"
  ]
}

data "template_file" "cert_manager_template" {
  template = file("./templates/cert-manager-values.yaml")
  vars = {
    CLUSTER_NAME   = local.cluster_name
    COMPARTMENT_ID = var.provider_id
  }
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "1.12.2"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  values = [data.template_file.cert_manager_template.rendered]
}

data "template_file" "cluster_wildcard_issuer" {
  template = file("./templates/cluster-issuer.yaml")
  vars = {
    email           = var.cert_issuer_config.email
    dns_zone_name   = local.domain_name
    compartment_id  = var.provider_id
    cert_issuer_url = try(var.cert_issuer_config.env == "stage" ? "https://acme-staging-v02.api.letsencrypt.org/directory" : "https://acme-v02.api.letsencrypt.org/directory","https://acme-staging-v02.api.letsencrypt.org/directory")
    tenancy_id      = var.provider_id
    fingerprint     = var.accessibility.fingerprint
    user_id         = var.accessibility.user_id
    region          = var.app_region
  }
  depends_on = [helm_release.cert_manager, kubernetes_namespace.monitoring]
}

resource "kubectl_manifest" "cluster_wildcard_issuer" {
  yaml_body = data.template_file.cluster_wildcard_issuer.rendered
}

data "template_file" "cluster_wildcard_certificate" {
  template = file("./templates/cluster-certificate.yaml")
  vars = {
    dns = local.domain_name
  }
  depends_on = [kubectl_manifest.cluster_wildcard_issuer]
}

resource "kubectl_manifest" "cluster_wildcard_certificate" {
  yaml_body = data.template_file.cluster_wildcard_certificate.rendered
}

resource "kubernetes_secret_v1" "certificate_replicator" {
  metadata {
    name      = "tls-secret-replica"
    namespace = "monitoring"
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
  depends_on = [helm_release.k8s_replicator]
}

resource "kubernetes_secret" "oci_api_key" {
  metadata {
    name      = "oci-api-key"
    namespace = "cert-manager"
  }

  data = {
    apiKey = local.private_key_content
  }

  type = "Opaque"

  depends_on = [ helm_release.cert_manager ]
}

data "template_file" "cert_manager_rbac" {
  template = file("${path.module}/templates/cluster-certificate-rbac.yaml")
  vars = {
    cluster_name = local.cluster_name
  }
}

resource "kubectl_manifest" "cert_manager_rbac" {
  yaml_body   = data.template_file.cert_manager_rbac.rendered
  depends_on  = [helm_release.cert_manager]
}