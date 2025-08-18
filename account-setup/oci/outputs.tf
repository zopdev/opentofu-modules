output "vcn_id" {
  description = "Map of VCN IDs"
  value = {
    for name, vcn in oci_core_vcn.vcn : name => vcn.id
  }
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value = [for subnet in oci_core_subnet.public_subnets : subnet.id]
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value = [for subnet in oci_core_subnet.private_subnets : subnet.id]
}

output "db_subnets" {
  description = "List of database subnet IDs"
  value = [for subnet in oci_core_subnet.db_subnets : subnet.id]
}

output "private_cidrs" {
  description = "List of private subnet CIDR blocks"
  value = [for subnet in oci_core_subnet.private_subnets : subnet.cidr_block]
}

output "available_services" {
  value = data.oci_core_services.all_services.services
}