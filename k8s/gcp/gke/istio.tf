# Install Istio base
resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = "istio-system"
  create_namespace = true
}

# Install Istiod without CNI
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
    value = "false"
  }

  # Exclude jobs and cronjobs from sidecar injection
  set {
    name  = "pilot.injectionPolicy"
    value = "enabled"
  }
  
  # Configure sidecar injection to exclude Job and CronJob resources
  set {
    name  = "pilot.resourcesToExclude"
    value = "Job,CronJob"
  }

  # Enable injection for specific pods in kube-system
  set {
    name  = "pilot.alwaysInjectSelector"
    value = "[{\"matchLabels\":{\"app\":\"nginx-ingress-controller\"}},{\"matchLabels\":{\"app.kubernetes.io/name\":\"ingress-nginx\"}}]"
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