resource "oci_artifacts_repository" "artifact_registry" {
  for_each        = toset(var.services)
  compartment_id  = var.provider_id
  is_immutable    = true
  repository_type = "GENERIC"
  display_name    = each.value
}
