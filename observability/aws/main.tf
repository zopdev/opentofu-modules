locals {
  access_secret      = urlencode(var.access_secret)
  access_key         = urlencode(var.access_key)
  cluster_name       = var.cluster_name
  cluster_name_parts = split("-", local.cluster_name)
  environment        = var.app_env == "" ? element(local.cluster_name_parts, length(local.cluster_name_parts) - 1) : var.app_env

  enable_loki   = try(var.loki != null ? var.loki.enable : false, false)
  enable_tempo  = try(var.tempo != null ? var.tempo.enable : false, false)
  enable_cortex = try(var.cortex != null ? var.cortex.enable : false, false)
  enable_mimir  = try(var.mimir != null ? var.mimir.enable : false,false)
  enable_openobserve = length(var.openobserve) > 0 && anytrue([for instance in var.openobserve : instance.enable])

  enable_ingress_loki = local.enable_loki ? (var.loki.enable_ingress != null ? var.loki.enable_ingress : false ) : false
  enable_ingress_tempo = local.enable_tempo ? (var.tempo.enable_ingress != null ? var.tempo.enable_ingress : false ) : false
  enable_ingress_mimir = local.enable_mimir ? (var.mimir.enable_ingress != null ? var.mimir.enable_ingress : false ) : false
  enable_ingress_cortex = local.enable_cortex ? (var.cortex.enable_ingress != null ? var.cortex.enable_ingress : false ) : false
  enable_ingress_openobserve = local.enable_openobserve ? anytrue([for instance in var.openobserve : instance.enable && try(instance.enable_ingress, true)]) : false

  app_namespaces = {
    loki = local.enable_loki ? {
      services = ["loki-distributor:3100", "loki-querier:3100"]
      ingress  = local.enable_ingress_loki
    } : null
    tempo = local.enable_tempo ? {
      services = ["tempo-distributor:9411"]
      ingress  = local.enable_ingress_tempo
    } : null
    cortex = local.enable_cortex ?  {
      services = ["cortex-distributor:8080"]
      ingress  = local.enable_ingress_cortex
    } : null
    mimir  = local.enable_mimir ? {
      services  = ["mimir-distributor:8080"]
      ingress  = local.enable_ingress_mimir
    } : null
    openobserve = local.enable_openobserve ? {
      services = [for instance in var.openobserve : "${instance.name}-openobserve-standalone:5080" if instance.enable && instance.enable_ingress != false]
      ingress  = local.enable_ingress_openobserve
    } : null
  }

  filtered_namespace = {
    for key, value in local.app_namespaces :
    key => value if value != null
  }
}

resource "kubernetes_namespace" "app_environments" {
  for_each = toset([for env in keys(local.app_namespaces) : env if env != "default" && local.app_namespaces[env] != null] )

  metadata {
    name = each.key
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

locals {
  services_list = merge([
    for ns in keys(local.app_namespaces) : {
      for service in local.app_namespaces[ns].services : "${service}-${ns}" => {
        service_name = split(":", service)[0]
        service_port = length(split(":", service)) != 2 ? 80 : split(":", service)[1]
        # domain_name backward compatible with namespace based names if app_env is not given, if app_env is given then new scheme is chosen
        domain_name = "${split(":", service)[0]}.${var.domain_name}"
        ns            = ns
        ingress_name  = "${split(":", service)[0]}-ingress"
      } if local.app_namespaces[ns].ingress == true
    } if local.app_namespaces[ns] != null
  ]...)
}

resource "kubernetes_ingress_v1" "service_ingress" {
  for_each = {for service, value in local.services_list : service => value}
  metadata {
    name      = each.value.ingress_name
    namespace = each.value.ns
    annotations = merge(
      {
      "kubernetes.io/ingress.class" = "nginx"
      },
      each.value.ns == "mimir" && local.enable_mimir ? {
        "nginx.ingress.kubernetes.io/auth-type"   = "basic"
        "nginx.ingress.kubernetes.io/auth-secret"  = "mimir-basic-auth"
        "nginx.ingress.kubernetes.io/auth-realm"  = "Authentication Required"
      } : {}
    )
  }
  spec {
    rule {
      host = each.value.domain_name
      http {
        path {
          backend {
            service {
              name = each.value.service_name
              port {
                number = each.value.service_port
              }
            }
          }
          path = "/"
        }
      }
    }
    tls {
      secret_name ="tls-secret-replica"
      hosts       = ["*.${var.domain_name}"]
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}
