resource "helm_release" "service_helm"{
  name        = "kops-kube"
  namespace   = "kube-system"
  repository  = "https://helm.zop.dev"
  version     = "v0.0.2"
  chart       = "service"

  set {
    name  = "name"
    value = "kops-kube"
  }

  set {
    name  = "image"
    value = "us-central1-docker.pkg.dev/raramuri-tech/kops-dev/kops-kube-azure:v0.0.14"
  }

  set_list {
    name = "imagePullSecrets"
    value = ["kops-kube-image-secrets"]
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
    name  = "maxCPU"
    value = "200m"
  }

  set {
    name  = "maxMemory"
    value = "500M"
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
    value = ["kops-kube-secret"]
  }

  values = [templatefile("./templates/values.yaml",{
    cluster_name = var.cluster_name
    app_region   = var.app_region
    cloud_platform = "AZURE"
    resource_group = var.resource_group_name
  })]
}



resource "kubernetes_ingress_v1" "kops_kube_ingress" {
  metadata {
    name      = "kops-kube-ingress"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }
  spec {
    rule {
      host = "kops-kube.${var.host}"
      http {
        path {
          backend {
            service {
              name = "kops-kube"
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
  depends_on = [kubernetes_secret_v1.namespace-cert-replicator]
}

resource "kubernetes_secret_v1" "namespace-cert-replicator" {
  metadata {
    name = "tls-secret-replica"
    namespace = "kube-system"
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
