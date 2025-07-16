locals {

  domain_name = try(var.accessibility.domain_name != null ? var.accessibility.domain_name : "", "")

  default_domain_list = merge([
    for service, service_config in var.services : {
      "${ service }" = {
        ingress   =  ["${split(":", service)[0]}-${var.namespace}.${local.domain_name}"]
        basic_auth = (service_config.enable_basic_auth != null ? service_config.enable_basic_auth : false) ? true : false
      }
    } if (coalesce(var.services[service].enable_default_ingress, false) == true)
  ]...)

  service_custom_domain_list = merge([
    for service, config in var.services : tomap({
        for host in config.ingress_list : "${service}-${var.namespace}-${host}" => {
        service_name       = split(":", service)[0]
        service_port       = length(split(":", service)) != 2 ? 80 : split(":", service)[1]
        ingress_host       = split("/", host)[0]
        path_based_routing = length(split("/", host)) != 2 ? "" : split("/", host)[1]
        ns                 = var.namespace
        ingress_name       = "${split(":", service)[0]}-${(replace(host, "/", "-"))}-ingress"
        basic_auth         = (config.enable_basic_auth != null ? config.enable_basic_auth : false) ? true : false
        nginx_rewrite      = config.nginx_rewrite != null ? config.nginx_rewrite : true
      }
      # Exclude wildcard hosts from custom host logic
      if !can(regex("^\\*\\.", split("/", host)[0]))
    })if try(length(var.services[service].ingress_list),0) != 0
  ]...)

  default_services_list = merge([
    for service in keys(local.default_domain_list) : {
      for ingress_name  in local.default_domain_list[service].ingress : "${service}-${var.namespace}-${ingress_name}" => {
        service_name = split(":", service)[0]
        service_port = length(split(":", service)) != 2 ? 80 : split(":", service)[1]
        # domain_name backward compatible with namespace based names if app_env is not given, if app_env is given then new scheme is chosen
        domain_name  = ingress_name
        ns           = var.namespace
        ingress_name = "${split(":", service)[0]}-${ingress_name}-ingress"
        basic_auth    = local.default_domain_list[service].basic_auth
      }
    }
  ]...)

  wildcard_custom_hosts = merge([
    for service, config in var.services : tomap({
      for host in try(config.ingress_list, []) :
        "${service}-${var.namespace}-${host}" => {
          service_name = split(":", service)[0]
          service_port = length(split(":", service)) != 2 ? 80 : split(":", service)[1]
          ingress_host = split("/", host)[0]
          ns           = var.namespace
          ingress_name = lower(replace("${split(":", service)[0]}-${replace(host, "/", "-")}-wildcard-ingress", "*", "wildcard"))
          base_domain  = replace(split("/", host)[0], "*.", "")
        }
        if can(regex("^\\*\\.", split("/", host)[0]))
    }) if try(length(config.ingress_list), 0) != 0
  ]...)

}

resource "random_password" "basic_auth_password" {
  for_each = {for k, v in var.services : k => v if v.enable_basic_auth != null ? v.enable_basic_auth : false }
  length           = 32
  special          = true
  override_special = "_@"
}

resource "random_string" "basic_auth_user_name_suffix" {
  for_each = {for k, v in var.services : k => v if v.enable_basic_auth != null ? v.enable_basic_auth : false }
  length  = 6
  special = true
  upper   = false
  numeric = false
  min_special = 2
  lower = true
}

resource "google_secret_manager_secret" "basic_auth_credentials" {
  for_each = {for k, v in var.services : k => v if v.enable_basic_auth != null ? v.enable_basic_auth : false }

  provider         = google-beta
  project          = var.provider_id
  secret_id        = "${local.cluster_name}-${var.namespace}-${each.key}-basic-auth-credentials"
  labels           = local.common_tags

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_iam_member" "basic_auth_credentials" {
  for_each    = {for k, v in var.services : k => v if v.enable_basic_auth != null ? v.enable_basic_auth : false }

  project     = var.provider_id
  secret_id   = google_secret_manager_secret.basic_auth_credentials[each.key].secret_id
  role        = "roles/secretmanager.secretAccessor"
  member      = "serviceAccount:${data.google_project.this.number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret_version" "basic_auth_credentials" {
  for_each        = {for k, v in var.services : k => v if v.enable_basic_auth != null ? v.enable_basic_auth : false }

  secret          = google_secret_manager_secret.basic_auth_credentials[each.key].id
  secret_data     = jsonencode({ user_name = "${each.key}-${random_string.basic_auth_user_name_suffix[each.key].result}",
                    password = random_password.basic_auth_password[each.key].result })
  depends_on      = [google_secret_manager_secret.basic_auth_credentials]
}

resource "kubernetes_secret_v1" "basic_auth_secret" {
  for_each = {for k, v in var.services : k => v if v.enable_basic_auth != null ? v.enable_basic_auth : false}

  metadata {
    name = "${each.key}-basic-auth"
    namespace = var.namespace
  }
  data = {
    auth = "${each.key}-${random_string.basic_auth_user_name_suffix[each.key].result}:${bcrypt(random_password.basic_auth_password[each.key].result)}"
  }
  type = "Opaque"
}

resource "kubernetes_ingress_v1" "default_service_ingress" {
  for_each = {for service, value in local.default_services_list : service => value }
  metadata {
    name      = each.value.ingress_name
    namespace = each.value.ns
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/auth-type" = each.value.basic_auth ? "basic" : ""
      "nginx.ingress.kubernetes.io/auth-secret" = each.value.basic_auth ? "${each.value.service_name}-basic-auth" : ""
      "nginx.ingress.kubernetes.io/auth-realm" = each.value.basic_auth ? "Authentication Required" : ""
    }
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
      secret_name = "tls-secret-replica"
      hosts       = ["*.${local.domain_name}"]
    }
  }
  depends_on = [kubernetes_namespace.app_environments]
}

resource "kubernetes_ingress_v1" "custom_service_ingress" {
  for_each = {for service, value in local.service_custom_domain_list : service => value if value.path_based_routing == "" }
  metadata {
    name      = each.value.ingress_name
    namespace = each.value.ns
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "cert-manager.io/issuer"      = "letsencrypt"
      "kubernetes.io/tls-acme"      = "true"
      "nginx.ingress.kubernetes.io/auth-type" = each.value.basic_auth ? "basic" : ""
      "nginx.ingress.kubernetes.io/auth-secret" = each.value.basic_auth ? "${each.value.service_name}-basic-auth" : ""
      "nginx.ingress.kubernetes.io/auth-realm" = each.value.basic_auth ? "Authentication Required" : ""

    }
  }
  spec {
    rule {
      host = each.value.ingress_host
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
      secret_name ="tls-secret-${each.value.ingress_host}"
      hosts       =[each.value.ingress_host]
    }
  }
  depends_on = [kubernetes_namespace.app_environments]
}

resource "kubernetes_ingress_v1" "custom_path_based_service_ingress" {
  for_each = {for service, value in local.service_custom_domain_list : service => value if value.path_based_routing != "" }
  metadata {
    name      = each.value.ingress_name
    namespace = each.value.ns
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "cert-manager.io/issuer"                     = "letsencrypt"
      "kubernetes.io/tls-acme"                     = "true"
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
      "nginx.ingress.kubernetes.io/rewrite-target" = each.value.nginx_rewrite ?  "/$2" : ""
      "nginx.ingress.kubernetes.io/auth-type" = each.value.basic_auth ? "basic" : ""
      "nginx.ingress.kubernetes.io/auth-secret" = each.value.basic_auth ? "${each.value.service_name}-basic-auth" : ""
      "nginx.ingress.kubernetes.io/auth-realm" = each.value.basic_auth ? "Authentication Required" : ""

    }
  }
  spec {
    rule {
      host = each.value.ingress_host
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
          path = each.value.nginx_rewrite ? "/${each.value.path_based_routing}(\\/|$)(.*)" : "/${each.value.path_based_routing}"
        }
      }
    }
    tls {
      secret_name ="tls-secret-${each.value.ingress_host}"
      hosts       =[each.value.ingress_host]
    }
  }
  depends_on = [kubernetes_namespace.app_environments]
}

resource "kubectl_manifest" "wildcard_certificate" {
  for_each = local.wildcard_custom_hosts
  yaml_body = templatefile("${path.module}/templates/cluster-certificate.yaml", {
    dns         = each.value.base_domain
    secret_name = each.value.ingress_name
    namespace   = each.value.ns
  })
}

resource "kubernetes_ingress_v1" "wildcard_custom_service_ingress" {
  for_each = local.wildcard_custom_hosts
  metadata {
    name      = each.value.ingress_name
    namespace = each.value.ns
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "kubernetes.io/tls-acme"      = "true"
    }
  }
  spec {
    rule {
      host = each.value.ingress_host
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
      secret_name = each.value.ingress_name
      hosts       = [each.value.ingress_host]
    }
  }
  depends_on = [kubectl_manifest.wildcard_certificate]
}

locals {
  ingress_tls_secrets = merge([
    for service_name, service in var.services : {
      for idx, ingress in try(service.ingress_with_secret, []) :
        "${service_name}-${idx}" => {
          host         = ingress.host
          tls_crt_key  = ingress.cloud_secret.tls_crt_key
          tls_key_key  = ingress.cloud_secret.tls_key_key
        }
    }
  ]...)
}

data "google_secret_manager_secret_version" "tls" {
  for_each = local.ingress_tls_secrets
  secret  = "tls-secret-${each.value.host}"
  version = "latest"
}

data "google_secret_manager_secret" "tls" {
  for_each = local.ingress_tls_secrets
  secret_id = "tls-secret-${each.value.host}"
  project   = var.provider_id
}

locals {
  tls_secret_data = {
    for k, v in local.ingress_tls_secrets :
    k => jsondecode(data.google_secret_manager_secret_version.tls[k].secret_data)
  }
}

resource "kubernetes_secret_v1" "tls" {
  for_each = local.ingress_tls_secrets
  metadata {
    name      = "tls-secret-${each.value.host}"
    namespace = var.namespace
  }
  data = {
    "tls.crt" = local.tls_secret_data[each.key][each.value.tls_crt_key]
    "tls.key" = local.tls_secret_data[each.key][each.value.tls_key_key]
  }
  type = "kubernetes.io/tls"
}

resource "kubernetes_ingress_v1" "service_ingress_with_secret" {
  for_each = merge([
    for service_name, service in var.services : {
      for idx, ingress in try(service.ingress_with_secret, []) :
        "${service_name}-${idx}" => {
          service_name = service_name
          host         = ingress.host
          cloud_secret = ingress.cloud_secret
          service_port = try(ingress.service_port, 80)
        }
    }
  ]...)

  metadata {
    name      = "ingress-with-secret-${each.key}"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      # Add more annotations as needed
    }
  }

  spec {
    rule {
      host = each.value.host
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
      secret_name = "tls-secret-${each.value.host}"
      hosts       = [each.value.host]
    }
  }
}