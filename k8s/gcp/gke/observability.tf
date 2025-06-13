locals {
  enable_loki   = try(var.observability_config.loki != null ? var.observability_config.loki.enable : false, false)
  enable_tempo  = try(var.observability_config.tempo != null ? var.observability_config.tempo.enable : false, false)
  enable_cortex = try(var.observability_config.cortex != null ? var.observability_config.cortex.enable : false, false)
  enable_mimir  = try(var.observability_config.mimir != null ? var.observability_config.mimir.enable : false,false)
}

module "observability" {
  count       =  (local.enable_cortex || local.enable_loki || local.enable_tempo || local.enable_mimir) ? 1: 0

  source = "../../../observability/gcp"

  app_name                = var.app_name
  app_region              = var.app_region
  project_id              = var.provider_id
  app_env                 = var.app_env
  domain_name             = try(var.accessibility.domain_name != null ? var.accessibility.domain_name : "", "")
  hosted_zone             = try(var.accessibility.hosted_zone != null ? var.accessibility.hosted_zone : "", "")
  observability_suffix    = var.observability_config.suffix
  labels                  = local.common_tags
  loki                    = var.observability_config.loki
  tempo                   = var.observability_config.tempo
  cortex                  = var.observability_config.cortex
  mimir                   = var.observability_config.mimir
  service_account_name_prefix = local.cluster_service_account_name

  providers = {
    google  = google
    google.shared-services = google.shared-services
  }

  depends_on = [helm_release.prometheus, helm_release.k8s_replicator]
}

# Install Kiali for Istio monitoring
resource "helm_release" "kiali" {
  name       = "kiali"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  namespace  = "istio-system"
  
  set {
    name  = "auth.strategy"
    value = "anonymous"
  }
  
  set {
    name  = "external_services.istio.root_namespace"
    value = "istio-system"
  }
  
  set {
    name  = "external_services.istio.istiod_url"
    value = "http://istiod.istio-system:15012"
  }

  set {
    name  = "external_services.prometheus.url"
    value = "http://prometheus-kube-prometheus-prometheus.monitoring:9090"
  }

  set {
    name  = "deployment.resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "deployment.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "deployment.resources.limits.memory"
    value = "256Mi"
  }

  set {
    name  = "deployment.resources.limits.cpu"
    value = "200m"
  }

  set {
    name  = "deployment.pod_annotations.kubernetes\\.io/ingress-bandwidth"
    value = "10M"
  }

  set {
    name  = "deployment.pod_annotations.kubernetes\\.io/egress-bandwidth"
    value = "10M"
  }
  
  depends_on = [helm_release.istiod]
}

# # Install Jaeger for Istio tracing
# resource "helm_release" "jaeger" {
#   name       = "jaeger"
#   repository = "https://jaegertracing.github.io/helm-charts"
#   chart      = "jaeger"
#   namespace  = "istio-system"
  
#   set {
#     name  = "query.service.type"
#     value = "ClusterIP"
#   }
  
#   set {
#     name  = "collector.service.type"
#     value = "ClusterIP"
#   }

#   set {
#     name  = "query.resources.requests.memory"
#     value = "128Mi"
#   }

#   set {
#     name  = "query.resources.requests.cpu"
#     value = "100m"
#   }

#   set {
#     name  = "query.resources.limits.memory"
#     value = "256Mi"
#   }

#   set {
#     name  = "query.resources.limits.cpu"
#     value = "200m"
#   }

#   set {
#     name  = "collector.resources.requests.memory"
#     value = "128Mi"
#   }

#   set {
#     name  = "collector.resources.requests.cpu"
#     value = "100m"
#   }

#   set {
#     name  = "collector.resources.limits.memory"
#     value = "256Mi"
#   }

#   set {
#     name  = "collector.resources.limits.cpu"
#     value = "200m"
#   }

#   set {
#     name  = "storage.type"
#     value = "memory"
#   }

#   set {
#     name  = "storage.options.memory.max-traces"
#     value = "50000"
#   }
  
#   depends_on = [helm_release.istiod]
# }


