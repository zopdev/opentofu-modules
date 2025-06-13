locals {
  # Create a map of services that need Istio configuration
  istio_services = merge([
    for service, value in local.default_services_list : {
      "${service}" = {
        service_name = value.service_name
        host        = value.domain_name
        namespace   = value.ns
      }
    }
  ]...)
}

# Create VirtualService for each service
resource "kubernetes_manifest" "virtual_service" {
  for_each = local.istio_services

  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "VirtualService"
    metadata = {
      name      = "${each.value.service_name}-vs"
      namespace = each.value.namespace
    }
    spec = {
      hosts = ["${each.value.service_name}.${each.value.namespace}.svc.cluster.local"]
      gateways = ["mesh"]
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
                host = "${each.value.service_name}.${each.value.namespace}.svc.cluster.local"
                port = {
                  number = 80
                }
              }
            }
          ]
          retries = {
            attempts = 3
            perTryTimeout = "2s"
          }
          timeout = "3s"
        }
      ]
    }
  }
}

# Create DestinationRule for each service
resource "kubernetes_manifest" "destination_rule" {
  for_each = local.istio_services

  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "DestinationRule"
    metadata = {
      name      = "${each.value.service_name}-dr"
      namespace = each.value.namespace
    }
    spec = {
      host = "${each.value.service_name}.${each.value.namespace}.svc.cluster.local"
      trafficPolicy = {
        tls = {
          mode = "ISTIO_MUTUAL"
        }
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
      subsets = [
        {
          name = "v1"
          labels = {
            version = "v1"
          }
        }
      ]
    }
  }
}

# Add ServiceEntry for external services if needed
resource "kubernetes_manifest" "service_entry" {
  for_each = local.istio_services

  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "ServiceEntry"
    metadata = {
      name      = "${each.value.service_name}-se"
      namespace = each.value.namespace
    }
    spec = {
      hosts = ["${each.value.service_name}.${each.value.namespace}.svc.cluster.local"]
      ports = [
        {
          number = 80
          name = "http"
          protocol = "HTTP"
        },
        {
          number = 443
          name = "https"
          protocol = "HTTPS"
        }
      ]
      resolution = "DNS"
      location = "MESH_INTERNAL"
    }
  }
} 