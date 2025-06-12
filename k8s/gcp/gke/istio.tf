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

# Install Istio CNI
resource "helm_release" "istio_cni" {
  name       = "istio-cni"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "cni"
  namespace  = "kube-system"
  
  set {
    name  = "cni.cniBinDir"
    value = "/home/kubernetes/bin"
  }

  set {
    name  = "cni.cniConfDir"
    value = "/etc/cni/net.d"
  }

  set {
    name  = "cni.cniConfFileName"
    value = "10-gke.conflist"
  }

  set {
    name  = "cni.chained"
    value = "true"
  }

  set {
    name  = "cni.logLevel"
    value = "info"
  }

  set {
    name  = "cni.excludeNamespaces"
    value = "[\"kube-system\",\"istio-system\"]"
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
    name  = "cni.repair.nodeName"
    value = "true"
  }

  set {
    name  = "cni.repair.sidecarAnnotation"
    value = "sidecar.istio.io/status"
  }

  set {
    name  = "cni.repair.initContainerName"
    value = "istio-validation"
  }

  set {
    name  = "cni.repair.brokenPodLabelKey"
    value = "cni.istio.io/uninitialized"
  }

  set {
    name  = "cni.repair.brokenPodLabelValue"
    value = "true"
  }

  set {
    name  = "cni.privileged"
    value = "true"
  }

  set {
    name  = "cni.psp.enabled"
    value = "false"
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