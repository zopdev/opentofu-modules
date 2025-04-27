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

# CSI Driver for secret stores, Helm Chart
resource "helm_release" "csi_driver" {
  chart      = "secrets-store-csi-driver"
  name       = "secrets-store-csi-driver"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  namespace  = "kube-system"
  version    = "1.3.0"
  
  set {
    name  = "syncSecret.enabled"
    value = "true"
  }
  
  depends_on = [null_resource.wait_for_cluster]
}

locals {
  oci_secrets_driver_yaml = split("---", file("./templates/oci-secrets-driver.yaml"))
}

resource "kubectl_manifest" "oci_secrets_driver" {
  for_each  = { for key, id in local.oci_secrets_driver_yaml : key => id }
  yaml_body = each.value
  depends_on = [module.oke] 
}