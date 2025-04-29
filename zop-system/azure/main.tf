resource "kubernetes_namespace" "app_environments" {
  metadata {
    name = "zop-system"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "helm_release" "service_helm"{
  name        = "kube-management-api"
  namespace   = "zop-system"
  repository  = "https://helm.zop.dev"
  version     = "v0.0.22"
  chart       = "service"

  set {
    name  = "name"
    value = "kube-management-api"
  }

  set {
    name  = "image"
    value = "us-central1-docker.pkg.dev/raramuri-tech/kops-dev/kube-management-api-azure:v0.0.29"
  }

  set_list {
    name = "imagePullSecrets"
    value = ["zop-system-image-secrets"]
  }

  set {
    name  = "replicaCount"
    value = 1
  }

  set {
    name  = "httpPort"
    value = 8000
  }

  set {
    name  = "metricsPort"
    value = 2121
  }

  set {
    name  = "minCPU"
    value = "100m"
  }

  set {
    name  = "minMemory"
    value = "100M"
  }

  set {
    name  = "minAvailable"
    value = 1
  }

  set {
    name  = "hpa_enable"
    value = true
  }

  set {
    name  = "minReplicas"
    value = 1
  }

  set {
    name  = "maxReplicas"
    value = 4
  }

  set {
    name  = "heartbeatURL"
    value = "./well-known/alive"
  }

  set_list {
    name = "envFrom.secrets"
    value = ["zop-system-secret"]
  }

  values = [templatefile("./templates/values.yaml",{
    cluster_name = var.cluster_name
    app_region   = var.app_region
    cloud_platform = "AZURE"
    resource_group = var.resource_group_name
    opencost_host = "opencost.monitoring:9003"
  })]
  depends_on = [kubernetes_namespace.app_environments]
}

resource "kubernetes_ingress_v1" "kube_management_api_ingress" {
  metadata {
    name      = "kube-management-api-ingress"
    namespace = "zop-system"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }
  spec {
    rule {
      host = "kube-management-api.${var.host}"
      http {
        path {
          backend {
            service {
              name = "kube-management-api"
              port {
                number = 8000
              }
            }
          }
          path = "/"
        }
      }
    }
    tls {
      secret_name = "tls-secret-replica"
      hosts       = ["*.${var.host}"]
    }
  }
  depends_on = [kubernetes_secret_v1.namespace-cert-replicator, kubernetes_namespace.app_environments]
}

resource "kubernetes_secret_v1" "namespace-cert-replicator" {
  metadata {
    name = "tls-secret-replica"
    namespace = "zop-system"
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
  depends_on = [kubernetes_namespace.app_environments]
}