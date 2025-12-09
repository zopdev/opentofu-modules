locals {
  badger_db_volume_mounts_services = tomap({
    for k, v in var.services : k => {
      (k) = {
        mount_path = "/etc/data"
      }
    } if coalesce(v.badger_db, false)
  })

  badger_db_volume_mounts_crons = tomap({
    for k, v in var.cron_jobs : k => {
      (k) = {
        mount_path = "/etc/data"
      }
    } if coalesce(v.badger_db, false)
  })

}