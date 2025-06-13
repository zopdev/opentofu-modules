# Install Istio base
resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = "istio-system"
  create_namespace = true
}

# Install Istiod with CNI awareness
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
    name  = "pilot.cni.enabled"
    value = "true"
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

# Install Istio CNI as a separate Helm release
resource "helm_release" "istio_cni" {
  name       = "istio-cni"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "cni"
  namespace  = "kube-system"

  set {
    name  = "cni.enabled"
    value = "true"
  }
  set {
    name  = "global.cni.enabled"
    value = "true"
  }
  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }
  set {
    name  = "cni.excludeNamespaces"
    value = "kube-system,istio-system,monitoring"
  }
  set {
    name  = "cni.repair.enabled"
    value = "true"
  }

  depends_on = [helm_release.istio_base]
}