output "name_servers" {
  value = {
    for k, v in var.zones : k =>
    aws_route53_zone.main[k].name_servers
  }
}