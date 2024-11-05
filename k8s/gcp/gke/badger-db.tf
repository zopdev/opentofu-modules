resource "kubernetes_storage_class_v1" "pd_ssd" {
  metadata {
    name = "pd-ssd"
  }
  storage_provisioner = "kubernetes.io/gce-pd"
  parameters = {
    type = "pd-ssd"
  }
}