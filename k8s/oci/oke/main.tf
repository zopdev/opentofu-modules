locals {
  cluster_name = var.app_env == "" ? var.app_name : "${var.app_name}-${var.app_env}"

  common_tags        = merge(var.common_tags,
    tomap({
      Project     = local.cluster_name,
      Provisioner = "Zopdev",
    }))
}

data "oci_containerengine_clusters" "cluster" {
    compartment_id = var.provider_id
    name = local.cluster_name
}

# OKE Module
module "oke" {
  source  = "oracle-terraform-modules/oke/oci"
  version = "5.2.4"
  providers = {
    oci.home = oci
  }

  compartment_id       = var.provider_id
  cluster_name         = local.cluster_name
  kubernetes_version   = "v1.32.1"

  create_vcn                            = false
  vcn_id                                = data.oci_core_vcn.vcn.id
  region                                = var.app_region
  cluster_type                          = "enhanced"

  create_bastion                        = false
  assign_public_ip_to_control_plane     = true
  control_plane_is_public               = true
  output_detail                         = true

  worker_compartment_id       = var.provider_id
  worker_pool_mode            = "node-pool"
  worker_image_type           = "oke"

  subnets = {
    cp       = { id = local.cp_subnet_ids}
    workers  = { id = local.worker_subnet_ids }
    pub_lb   = { id = local.publb_subnet_ids }
  }

  worker_pools = {
    np1 = {
      shape              = var.node_config.node_type,
      ocpus              = var.node_config.opus, 
      memory             = var.node_config.memory, 
      size               = var.node_config.size,
      boot_volume_size   = var.node_config.boot_volume_size,
      kubernetes_version = "v1.32.1"
    }
  }

  freeform_tags = merge(
    { for k, v in local.common_tags : k => tostring(v) }, 
    { "Name" = local.cluster_name }
  )
}
