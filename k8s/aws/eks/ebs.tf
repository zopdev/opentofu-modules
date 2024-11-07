data "aws_eks_addon_version" "this" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = module.eks.cluster_version
  most_recent        = true
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name             = local.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = data.aws_eks_addon_version.this.version
  resolve_conflicts        =  "OVERWRITE"
  service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
  preserve                 = true

  tags = merge(local.common_tags,
    tomap({
      "ebs.csi.aws.com/cluster" = "true"
      "CSIVolumeName" =  "gp2"
    }))

  depends_on = [module.ebs_csi_irsa_role]
}

module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${local.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}