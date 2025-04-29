resource "null_resource" "wait_for_cluster" {
  provisioner "local-exec" {
    command = "sleep 20"  
  }
  depends_on = [module.oke]
}

data "template_file" "autoscale_template" {
  template = file("./templates/cluster-auto-scaler-values.yaml")
  vars = {
    CLUSTER_NAME   = local.cluster_name
    REGION         = var.app_region
  }
}

resource "helm_release" "auto_scaler" {
  chart      = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.28.0"

  values = [data.template_file.autoscale_template.rendered]

  depends_on = [null_resource.wait_for_cluster]
} 