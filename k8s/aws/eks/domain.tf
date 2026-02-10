locals {
  domain_name = try(var.accessibility.domain_name != null ? var.accessibility.domain_name  : "", "")
}

data "aws_route53_zone" "zone" {
  count        = var.accessibility.domain_name == "" ? 0 : 1
  provider     = aws.shared-services
  name         = var.accessibility.domain_name
  private_zone = false
}

data "kubernetes_service" "ingress-controller" {
  metadata {
    name      = "${local.cluster_name}-ingress-nginx-controller"
    namespace = "kube-system"
  }
  depends_on = [module.nginx]
}

resource "aws_route53_record" "c_name_record" {
  provider = aws.shared-services
  zone_id  = data.aws_route53_zone.zone.0.zone_id
  name     = "*.${local.domain_name}"
  type     = "CNAME"
  records  = [data.kubernetes_service.ingress-controller.status.0.load_balancer.0.ingress.0.hostname]
  ttl      = 300
}

#resource "aws_route53_record" "c_name_record_public" {
#  provider = aws.shared-services
#  zone_id  = data.aws_route53_zone.zone.0.zone_id
#  name     = local.domain_name
#  type     = "CNAME"
#  ttl      = 300
#  records  = [data.kubernetes_service.ingress-controller.status.0.load_balancer.0.ingress.0.hostname]
#}
