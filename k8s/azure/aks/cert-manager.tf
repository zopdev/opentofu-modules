locals {
  cert_manager_template = templatefile(
    "${path.module}/templates/cert-manager-values.yaml",
    {}
  )

  cluster_wildcard_issuer = templatefile(
    "${path.module}/templates/cluster-issuer.yaml",
    {
      DNS                 = var.accessibility.domain_name
      cert_issuer_url     = try(
          var.cert_issuer_config.env == "stage" ?
          "https://acme-staging-v02.api.letsencrypt.org/directory" :
          "https://acme-v02.api.letsencrypt.org/directory",
        "https://acme-staging-v02.api.letsencrypt.org/directory"
      )
      location            = var.app_region
      RESOURCE_GROUP_NAME = var.resource_group_name
      SUBSCRIPTION_ID     = data.azurerm_subscription.current.subscription_id
      CLIENT_ID           = data.azurerm_kubernetes_cluster.cluster.kubelet_identity[0].client_id
      email               = var.cert_issuer_config.email
      dns_zone_list       = join(",", var.dns_zone_list)
    }
  )

  cluster_wildcard_certificate = templatefile(
    "${path.module}/templates/cluster-certificate.yaml",
    {
      dns = local.domain_name
    }
  )
}

resource "azurerm_role_assignment" "cert-manager" {
  scope                = data.azurerm_dns_zone.dns_zone.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = data.azurerm_kubernetes_cluster.cluster.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "cert-manager-additional-zones" {
  for_each             = toset(var.dns_zone_list)
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/dnsZones/${each.value}"
  role_definition_name = "DNS Zone Contributor"
  principal_id         = data.azurerm_kubernetes_cluster.cluster.kubelet_identity[0].object_id
}

resource "azurerm_federated_identity_credential" "cert-manager" {
  name                = "${local.cluster_name}-dns"
  resource_group_name = data.azurerm_kubernetes_cluster.cluster.node_resource_group
  issuer              = module.aks.oidc_issuer_url
  parent_id           = data.azurerm_kubernetes_cluster.cluster.kubelet_identity[0].user_assigned_identity_id
  subject             = "system:serviceaccount:cert-manager:cert-manager"
  audience            = ["api://AzureADTokenExchange"]
}

resource "helm_release" "cert_manager" {
  name         = "cert-manager"
  repository   = "https://charts.jetstack.io"
  chart        = "cert-manager"
  version      = "1.13.0"
  namespace    = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  values = [local.cert_manager_template]
}

resource "kubectl_manifest" "cluster_wildcard_issuer" {
  yaml_body = local.cluster_wildcard_issuer
}

resource "kubectl_manifest" "cluster_wildcard_certificate" {
  yaml_body = local.cluster_wildcard_certificate
}

resource "kubernetes_secret_v1" "certificate_replicator" {
  metadata {
    name = "tls-secret-replica"
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