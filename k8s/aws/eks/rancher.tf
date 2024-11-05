#module "rancher" {
# source = "<TODO Add Rancher Module source here>"
#
#  # cluster_name = "${local.cluster_name}"
#  cluster_name = module.eks.cluster_id
#  rancher_import_enabled = var.rancher_import_enabled
#  app_env        = var.app_env == "" ? element(local.cluster_name_parts, length(local.cluster_name_parts) - 1) : var.app_env
#  providers = {
#    aws = aws
#    aws.shared_aws_profile = aws.shared_aws_profile
#  }
#}
