resource "google_service_account" "wildcard_dns_solver" {
  account_id   = "${local.cluster_name}-wildcard"
  display_name = "${local.cluster_name} wildcard dns01 solver"
  description  = "Service Account created for Wildcard Certificates in ${local.cluster_name} gke cluster"
}

resource "google_project_iam_member" "wildcard_dns01_solver_dns_admin" {
  provider    = google.shared-services
  project     =  var.shared_service_provider
  role        = "roles/dns.admin"
  member      = "serviceAccount:${google_service_account.wildcard_dns_solver.email}"
}

resource "google_project_iam_member" "wildcard_dns_solver_workloadIdentity" {
  project     =  var.provider_id
  role        = "roles/iam.workloadIdentityUser"
  member      = "serviceAccount:${google_service_account.wildcard_dns_solver.email}"
}

resource "google_project_iam_member" "wildcard_dns_solver" {
  project    =  var.provider_id
  role       = "roles/iam.workloadIdentityUser"
  member     = "serviceAccount:${var.provider_id}.svc.id.goog[cert-manager/${local.cluster_name}-cert-manager]"
  depends_on = [helm_release.cert-manager]
}

resource "google_project_iam_member" "wildcard_dns_solver_iam" {
  project   =  var.provider_id
  role      = "roles/iam.serviceAccountTokenCreator"
  member    = "serviceAccount:${google_service_account.wildcard_dns_solver.email}"
}

data "template_file" "cert_manager_template" {
  template = file("./templates/cert-manager-values.yaml")
  vars     = {
    CLUSTER_NAME    = local.cluster_name
    SERVICE_ACCOUNT = google_service_account.wildcard_dns_solver.email
  }
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "1.12.2"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  values = [data.template_file.cert_manager_template.rendered]
}


data "template_file" "cluster_wildcard_issuer" {
  template = file("./templates/cluster-issuer.yaml")
  vars     = {
    email           = var.cert_issuer_config.email
    provider        = var.shared_service_provider
    dns             = local.domain_name
    cert_issuer_url = try(var.cert_issuer_config.env == "stage" ? "https://acme-staging-v02.api.letsencrypt.org/directory" : "https://acme-v02.api.letsencrypt.org/directory","https://acme-staging-v02.api.letsencrypt.org/directory")
  }
  depends_on = [helm_release.cert-manager,kubernetes_namespace.monitoring]
}

resource "kubectl_manifest" "cluster_wildcard_issuer" {
  yaml_body = data.template_file.cluster_wildcard_issuer.rendered
}

data "template_file" "cluster_wildcard_certificate" {
  template = file("./templates/cluster-certificate.yaml")
  vars     = {
    dns       = local.domain_name
  }
  depends_on = [kubectl_manifest.cluster_wildcard_issuer]
}

resource "kubectl_manifest" "cluster_wildcard_certificate" {
  yaml_body = data.template_file.cluster_wildcard_certificate.rendered
}

resource "kubernetes_secret_v1" "certificate_replicator" {
  metadata {
    name = "tls-secret-replica"
    namespace = "monitoring"
    annotations = {
      "replicator.v1.mittwald.de/replicate-from" = "cert-manager/wildcard-dns"
    }
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.key" = ""
    "tls.crt" = ""
  }
  lifecycle {
    ignore_changes = all
  }
  depends_on = [helm_release.k8s_replicator]
}

resource "kubernetes_manifest" "default_virtual_service_cert" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "VirtualService"
    metadata = {
      name      = "default-virtual-service"
      namespace = helm_release.cert-manager.namespace
    }
    spec = {
      hosts = ["*.${helm_release.cert-manager.namespace}.svc.cluster.local"]
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
                host = "*.${helm_release.cert-manager.namespace}.svc.cluster.local"
              }
            }
          ]
        }
      ]
    }
  }
  depends_on = [helm_release.istio_base,helm_release.istiod, helm_release.istio_cni]

}