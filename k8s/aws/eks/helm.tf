data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.name
}


provider "helm" {
  kubernetes {
    host                   = module.eks.endpoint
    cluster_ca_certificate = base64decode(module.eks.certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}


# Same parameters as kubernetes provider
provider "kubectl" {
  load_config_file       = false
  host                   = module.eks.endpoint
  cluster_ca_certificate = base64decode(module.eks.certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}