locals {
  editors = try(var.user_access.editors,[])
  viewers = try(var.user_access.viewers,[])
  add_viewers = local.viewers == null ? false : true
  add_editors = local.editors == null ? false : true
}

resource "google_dns_managed_zone" "dns_zone" {
  for_each = var.zones
  name        = each.key
  dns_name    = each.value.domain
  description = "created by ${var.provisioner}"
  labels = {
    provisioner = var.provisioner
  }
}

resource "google_project_iam_member" "dns_admin" {
  for_each = local.add_editors ? toset(local.editors) : toset([])
  project   = var.provider_id
  role      = "roles/dns.admin"
  member    = "user:${ each.value }"
}

resource "google_project_iam_member" "dns_viewer" {
  for_each = local.add_viewers ? toset(local.viewers) : toset([])
  project   = var.provider_id
  role      = "roles/dns.reader"
  member    = "user:${ each.value }"
}

data "google_dns_managed_zone" "zone" {
  provider    = google.shared-services
  count = try(var.master_zone != ""? true : false,false) ? 1 :0
  name         = var.master_zone
}

resource "google_dns_record_set" "aws_ns" {
  provider = google.shared-services
  for_each = { for k , v in var.zones : k => v if v.add_ns_records }
  name = google_dns_managed_zone.dns_zone[each.key].dns_name
  type = "NS"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.zone[0].name
  rrdatas = google_dns_managed_zone.dns_zone[each.key].name_servers
}

resource "google_dns_record_set" "caa_records" {
  provider = google.shared-services
  for_each = { for k , v in var.zones : k => v if v.add_ns_records }
  name = google_dns_managed_zone.dns_zone[each.key].dns_name
  type        = "CAA"
  ttl         = 300
  managed_zone = data.google_dns_managed_zone.zone[0].name
  rrdatas = try(var.caa_certs,[])
}

terraform {
  backend "gcs" {}
}

