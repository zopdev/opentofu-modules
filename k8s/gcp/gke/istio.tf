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
    name  = "global.proxy.autoInject"
    value = "enabled"
  }

  # Disable priority class to avoid quota issues
  set {
    name  = "cni.priorityClassName"
    value = ""
  }

  # Set lower priority for CNI daemon set
  set {
    name  = "cni.daemonSet.priorityClassName"
    value = ""
  }

  # Disable system critical priority
  set {
    name  = "cni.daemonSet.priority"
    value = "0"
  }

  set {
    name  = "cni.repair.enabled"
    value = "true"
  }

  set {
    name  = "cni.repair.deletePods"
    value = "true"
  }

  set {
    name  = "cni.repair.labelPods"
    value = "true"
  }

  set {
    name  = "cni.repair.nodeSelector"
    value = "{}"
  }

  depends_on = [helm_release.istio_base]
}