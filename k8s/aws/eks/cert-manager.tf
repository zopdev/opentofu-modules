resource "null_resource" "wait_for_cluster" {
  provisioner "local-exec" {
    command = "sleep 60"  # Adjust the duration as needed
  }

  depends_on = [module.eks]
}

data "template_file" "cert_manager_template" {
  template = file("./templates/cert-manager-values.yaml")
  vars     = {
    CLUSTER_NAME    = local.cluster_name
    role_arn        = aws_iam_role.cluster_issuer_role.arn
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

  depends_on = [null_resource.wait_for_cluster]
}

resource "aws_iam_policy" "cluster_issuer" {
  name        = "${local.cluster_name}-cluster-issuer-policy"
  policy      = data.aws_iam_policy_document.cluster_issuer_policy_document.json
  tags        = local.common_tags
}

data "aws_iam_policy_document" "cluster_issuer_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "route53:GetChange"
    ]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]
    resources = ["arn:aws:route53:::hostedzone/${data.aws_route53_zone.zone.0.zone_id}"]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZonesByName",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "cluster_issuer_role" {
  name  = "${local.cluster_name}-cluster-issuer-role"

  assume_role_policy = jsonencode({
    Version: "2012-10-17"
      Statement: [
        {
          "Sid": "",
          "Action": "sts:AssumeRole"
          "Effect": "Allow"
          "Principal": {
            "Service": "ec2.amazonaws.com"
          }
        }
      ]
    })
}

resource "aws_iam_user" "cluster_issuer" {
  name      =  "${local.cluster_name}-issuer-user"
  tags      =  local.common_tags
}

resource "aws_iam_user_policy_attachment" "cluster_issuer_attach" {
  user       = aws_iam_user.cluster_issuer.name
  policy_arn = aws_iam_policy.cluster_issuer.arn
}

resource "aws_iam_access_key" "cluster_issuer_user" {
  user = aws_iam_user.cluster_issuer.name
}

resource "kubernetes_secret" "cluster_issuer_credentials" {
  metadata {
    name      = "${local.cluster_name}-cluster-issuer-creds"
    namespace = "cert-manager"
  }

  type = "Opaque"

  data = {
    "access-key-id"     = aws_iam_access_key.cluster_issuer_user.id
    "access-key-secret" = aws_iam_access_key.cluster_issuer_user.secret
  }

  depends_on = [helm_release.cert-manager]
}

data "template_file" "cluster_wildcard_issuer" {
  template = file("./templates/cluster-issuer.yaml")
  vars     = {
    dns             = local.domain_name
    cert_issuer_url = try(var.cert_issuer_config.env == "stage" ? "https://acme-staging-v02.api.letsencrypt.org/directory" : "https://acme-v02.api.letsencrypt.org/directory","https://acme-staging-v02.api.letsencrypt.org/directory")
    location        = var.app_region
    zone_id         = data.aws_route53_zone.zone.0.zone_id
    secret_name     = "${local.cluster_name}-cluster-issuer-creds"
    email           = var.cert_issuer_config.email
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
  depends_on = [helm_release.k8s_replicator, kubernetes_namespace.monitoring]
}