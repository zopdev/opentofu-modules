resource "oci_kms_vault" "oci_vault" {
  compartment_id = var.provider_id
  display_name   = "${local.cluster_name}-vault"
  vault_type     = "DEFAULT"  
  
  defined_tags   = var.common_tags
}

resource "oci_kms_key" "oci_key" {
  compartment_id      = var.provider_id
  display_name        = "${local.cluster_name}-key"
  management_endpoint = oci_kms_vault.oci_vault.management_endpoint
  
  key_shape {
    algorithm = "AES"
    length    = 32  
  }

  defined_tags  = var.common_tags
}

resource "helm_release" "csi_driver" {
  chart      = "oci-secrets-store-csi-driver-provider"
  name       = "oci-secrets-store-csi-driver"
  repository = "https://oracle.github.io/oci-secrets-store-csi-driver-provider/charts"
  namespace  = "kube-system"
  version    = "0.4.1"
  
  set {
    name  = "secrets-store-csi-driver.syncSecret.enabled"
    value = "true"
  }
  
  depends_on = [null_resource.wait_for_cluster]
}