resource "helm_release" "redis" {
  name       = "redis-master"
  namespace  = var.namespace
  chart      = "oci://registry-1.docker.io/bitnamicharts/redis"
  version    = "19.5.0"
  timeout    = 120
  values     = [templatefile("${path.module}/templates/values.yaml", {
    redis_name    = "redis-master"
    disk_size     = var.disk_size
    storage_class = var.storage_class
    max_cpu       = var.max_cpu
    min_cpu       = var.min_cpu
    max_memory    = var.max_memory
    min_memory    = var.min_memory
  })]
}