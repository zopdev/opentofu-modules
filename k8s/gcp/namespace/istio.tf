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
      hosts = [each.value.host]
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
                host = each.value.service_name
                port = {
                  number = 80
                }
              }
            }
          ]
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
      host = each.value.service_name
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
    }
  }
} 