resource "oci_artifacts_container_repository" "artifact_registry" {
  for_each       = toset(var.services)
  compartment_id = var.provider_id
  display_name   = each.value
  is_public      = false  
}
