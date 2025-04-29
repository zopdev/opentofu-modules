locals {
     worker_subnet_ids = data.oci_core_subnets.worker_subnets_cidrs.subnets[0].id
     cp_subnet_ids     = data.oci_core_subnets.cp_subnets_cidrs.subnets[0].id
     publb_subnet_ids  = data.oci_core_subnets.publb_subnets_cidrs.subnets[0].id
     db_subnet_ids     = data.oci_core_subnets.db_subnets_cidrs.subnets[0].id
     vcn_id            = data.oci_core_subnets.worker_subnets_cidrs.subnets[0].vcn_id
}

data "oci_core_vcn" "vcn" {
  vcn_id   = local.vcn_id
}

data "oci_core_subnets" "worker_subnets_cidrs" {
  compartment_id = var.provider_id
  filter {
    name   = "freeform_tags.Environment"
    values = ["node"]
  }
}

data "oci_core_subnets" "cp_subnets_cidrs" {
  compartment_id = var.provider_id
  filter {
    name   = "freeform_tags.Environment"
    values = ["k8sapi"]
  }
}

data "oci_core_subnets" "publb_subnets_cidrs" {
  compartment_id = var.provider_id
  filter {
    name   = "freeform_tags.Environment"
    values = ["svclb"]
  }
}

data "oci_core_subnets" "db_subnets_cidrs" {
  compartment_id = var.provider_id
  filter {
    name   = "freeform_tags.Type"
    values = ["DB"]
  }
}