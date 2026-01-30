locals {
  autoscale_template = templatefile(
    "${path.module}/templates/cluster-auto-scaler-values.yaml",
    {
      CLUSTER_REGION = var.app_region
      CLUSTER_NAME   = local.cluster_name
      ACCOUNT_ID     = data.aws_caller_identity.current.account_id
    }
  )
}

resource "helm_release" "auto_scaler" {
  chart      = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.50.0"

  values = [local.autoscale_template]

  depends_on = [null_resource.wait_for_cluster]
}