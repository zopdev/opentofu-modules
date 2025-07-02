data "template_file" "autoscale_template" {
  template = file("./templates/cluster-auto-scaler-values.yaml")
  vars = {
    CLUSTER_REGION = var.app_region
    CLUSTER_NAME   = local.cluster_name
    ACCOUNT_ID     = data.aws_caller_identity.current.account_id
  }
}

resource "helm_release" "auto_scaler" {
  chart      = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.46.6"

  values = [data.template_file.autoscale_template.rendered]

  depends_on = [null_resource.wait_for_cluster]
}