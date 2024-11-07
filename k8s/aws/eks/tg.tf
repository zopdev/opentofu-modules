resource "aws_lb_target_group" "kong_tg_admin" {
  count = var.public_ingress ? 1 : 0

  name     = "${local.cluster_name}-tg-admin"
  port     = local.node_port
  protocol = "HTTPS"
  vpc_id   = local.vpc_id
  tags     = local.common_tags

  health_check {
    matcher = "400"
  }
}