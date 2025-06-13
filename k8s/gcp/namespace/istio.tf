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

# Create a default DestinationRule for services
resource "kubernetes_manifest" "default_destination_rule" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "DestinationRule"
    metadata = {
      name      = "default-destination-rule"
      namespace = var.namespace
    }
    spec = {
      host = "*.${var.namespace}.svc.cluster.local"
      trafficPolicy = {
        loadBalancer = {
          simple = "ROUND_ROBIN"
        }
        connectionPool = {
          tcp = {
            maxConnections = 100
          }
          http = {
            http1MaxPendingRequests = 1024
            maxRequestsPerConnection = 10
          }
        }
        outlierDetection = {
          consecutive5xxErrors = 5
          interval = "30s"
          baseEjectionTime = "30s"
          maxEjectionPercent = 10
        }
      }
    }
  }
}

# Create a default VirtualService for service-to-service communication
resource "kubernetes_manifest" "default_virtual_service" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "VirtualService"
    metadata = {
      name      = "default-virtual-service"
      namespace = var.namespace
    }
    spec = {
      hosts = ["*.${var.namespace}.svc.cluster.local"]
      http = [
        {
          match = [
            {
              uri = {
                prefix = "/"
              }
            }
          ]
          route = [
            {
              destination = {
                host = "*.${var.namespace}.svc.cluster.local"
              }
            }
          ]
        }
      ]
    }
  }
}

# Create a default ServiceEntry for external services
resource "kubernetes_manifest" "external_services" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "ServiceEntry"
    metadata = {
      name      = "external-services"
      namespace = var.namespace
    }
    spec = {
      hosts = ["api.external-service.com"]
      ports = [
        {
          number = 443
          name = "https"
          protocol = "HTTPS"
        }
      ]
      resolution = "DNS"
      location = "MESH_EXTERNAL"
    }
  }
}

# Create a default Sidecar resource
resource "kubernetes_manifest" "default_sidecar" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "Sidecar"
    metadata = {
      name      = "default-sidecar"
      namespace = var.namespace
    }
    spec = {
      workloadSelector = {
        labels = {
          app = "*"
        }
      }
      egress = [
        {
          hosts = [
            "./*",
            "istio-system/*"
          ]
        }
      ]
    }
  }
} 