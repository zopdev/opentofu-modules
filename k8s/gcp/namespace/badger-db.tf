locals {
  badger_db_volume_mounts_services = tomap({
    for k, v in var.services : k => {
      "${k}" = {
        mount_path = "/etc/data"
      }
    } if coalesce(v.badger_db, false)
  })

  badger_db_volume_mounts_crons = tomap({
    for k, v in var.cron_jobs : k => {
      "${k}" = {
        mount_path = "/etc/data"
      }
    } if coalesce(v.badger_db, false)
  })

}

resource "kubernetes_persistent_volume_claim_v1" "badger_db_for_services" {
  for_each = {for k,v in var.services : k => v if v.badger_db!= null ? v.badger_db : false }
  metadata {
    name = each.key
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1.5Gi"
      }
    }
    storage_class_name = "pd-ssd"
    volume_mode = "Filesystem"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "service_pvc" {
  for_each = {
    for k, v in var.services : k => v
    if try(v.helm_configs.volume_mounts.pvc != null, false)
  }

  metadata {
    name      = each.key
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1.5Gi"
      }
    }
    storage_class_name = "pd-ssd"
    volume_mode        = "Filesystem"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "badger_db_for_crons" {
  for_each = {for k,v in var.cron_jobs : k => v if v.badger_db!= null ? v.badger_db : false}
  metadata {
    name = each.key
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1.5Gi"
      }
    }
    storage_class_name = "pd-ssd"
    volume_mode = "Filesystem"
  }
}