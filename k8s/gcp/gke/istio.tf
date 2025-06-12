# Install Istio base
resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = "istio-system"
  create_namespace = true
}

# Install Istiod
resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = "istio-system"
  
  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }

  set {
    name  = "global.proxy.autoInject"
    value = "enabled"
  }

  set {
    name  = "global.proxy.enableCoreDump"
    value = "false"
  }

  set {
    name  = "global.proxy.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "global.proxy.resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "global.proxy.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "global.proxy.resources.limits.memory"
    value = "512Mi"
  }

  depends_on = [helm_release.istio_base]
}

# Create Istio system namespace
resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
    labels = {
      "istio-injection" = "disabled"
    }
  }
} 