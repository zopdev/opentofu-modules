resource "aws_route53_zone" "main" {
  for_each = var.zones
  name     = each.value.domain
}

data "google_dns_managed_zone" "zone" {
  provider    = google.shared-services
  count = try(var.master_zone != ""? true : false,false) ? 1 :0
  name         = var.master_zone
}

resource "google_dns_record_set" "aws_ns" {
  provider    = google.shared-services
  for_each     = { for k , v in var.zones : k => v if v.add_ns_records }
  name = "${aws_route53_zone.main[each.key].name}."
  type = "NS"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.zone[0].name
  rrdatas = try([for ns in aws_route53_zone.main[each.key].name_servers : "${ns}."],"")
}

#resource "aws_route53_record" "caa_record" {
#  count = try(var.accessibility.create_zone,false) ? 1 :0
#  name = aws_route53_zone.main[0].name
#  type = "CAA"
#  zone_id = aws_route53_zone.main[0].zone_id
#  ttl  = 300
#  records = ["0 issue \"amazonaws.com\"",]
#}
