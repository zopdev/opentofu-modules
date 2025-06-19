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

  # Configure the sidecar injector webhook
  set {
    name  = "sidecarInjectorWebhook.enableNamespacesByDefault"
    value = "false"
  }

  # Custom webhook configuration to target specific pods in kube-system
  values = [
    yamlencode({
      sidecarInjectorWebhook = {
        # Enable the webhook
        enabled = true

        # Custom webhook configuration
        webhookName = "istio-sidecar-injector"

        # Namespace selector configuration
        namespaceSelector = {
          matchExpressions = [
            {
              key      = "name"
              operator = "NotIn"
              values   = ["kube-public", "kube-node-lease"]
            }
          ]
        }

        # Object selector for targeting specific pods
        objectSelector = {
          matchExpressions = [
            {
              key      = "sidecar.istio.io/inject"
              operator = "In"
              values   = ["true"]
            }
          ]
        }

        # Injection policy
        policy = "enabled"

        # Template for injection
        template = <<-EOT
          policy: enabled
          alwaysInjectSelector:
            - matchExpressions:
              - key: app.kubernetes.io/name
                operator: In
                values: ["ingress-nginx"]
          neverInjectSelector:
            - matchExpressions:
              - key: app.kubernetes.io/name
                operator: NotIn
                values: ["ingress-nginx"]
        EOT
      }
    })
  ]

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