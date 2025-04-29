resource "helm_release" "k8s_replicator" {
  repository = "https://helm.mittwald.de"
  chart = "kubernetes-replicator"
  name  = "kubernetes-replicator"
  version = "2.9.0"
  timeout = 1200
  namespace = "kube-system"
  values = [
    file("./templates/mettwald-replicator.yaml")
  ]
}