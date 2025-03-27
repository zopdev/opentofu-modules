locals {
  public_subnet_map = merge([
    for vcn_name in keys(var.subnets) : tomap({
      for subnet in var.subnets[vcn_name].public_subnets_cidr : "${vcn_name}-${subnet}" => {
        vcn_id = oci_core_vcn.vcn[vcn_name].id
        subnet = subnet
        compartment_id = var.provider_id
      }
    })
  ]...)

  private_subnet_map = merge([
    for vcn_name in keys(var.subnets) : tomap({
      for subnet in var.subnets[vcn_name].private_subnets_cidr : "${vcn_name}-${subnet}" => {
        vcn_id = oci_core_vcn.vcn[vcn_name].id
        subnet = subnet
        compartment_id = var.provider_id
      }
    })
  ]...)

  db_subnet_map = merge([
    for vcn_name in keys(var.subnets) : tomap({
      for subnet in var.subnets[vcn_name].db_subnets_cidr : "${vcn_name}-${subnet}" => {
        vcn_id = oci_core_vcn.vcn[vcn_name].id
        subnet = subnet
        compartment_id = var.provider_id
      }
    })
  ]...)
}

resource "oci_core_vcn" "vcn" {
  for_each       = var.subnets
  
  compartment_id = var.provider_id
  cidr_blocks    = [each.value.vpc_cidr]
  
  display_name   = "${each.key}-vcn"
  
  freeform_tags = {
    Environment = each.key
    Name        = "${each.key}-vcn"
  }
}

resource "oci_core_subnet" "public_subnets" {
  for_each       = local.public_subnet_map
  
  compartment_id = var.provider_id
  vcn_id         = each.value.vcn_id
  cidr_block     = each.value.subnet
  
  display_name   = "${each.key}-public-subnet"
  
  route_table_id = oci_core_route_table.public_route_table[split("-", each.key)[0]].id
  
  prohibit_public_ip_on_vnic = false
  
  freeform_tags = {
    Environment = each.key
    Name        = "${each.key}-public-subnet"
  }
  depends_on = [ oci_core_vcn.vcn ]
}

resource "oci_core_subnet" "private_subnets" {
  for_each       = local.private_subnet_map
  
  compartment_id = var.provider_id
  vcn_id         = each.value.vcn_id
  cidr_block     = each.value.subnet
  
  display_name   = "${each.key}-private-subnet"
  
  route_table_id = oci_core_route_table.private_route_table[each.key].id
  
  prohibit_public_ip_on_vnic = true
  
  freeform_tags = {
    Environment = each.key
    Name        = "${each.key}-private-subnet"
  }
  depends_on = [ oci_core_vcn.vcn ]
}

resource "oci_core_subnet" "db_subnets" {
  for_each       = local.db_subnet_map
  
  compartment_id = var.provider_id
  vcn_id         = each.value.vcn_id
  cidr_block     = each.value.subnet
  
  display_name   = "${each.key}-db-subnet"
  
  route_table_id = oci_core_route_table.db_route_table[each.key].id
  
  prohibit_public_ip_on_vnic = true
  
  freeform_tags = {
    Environment = each.key
    Name        = "${each.key}-db-subnet"
  }
  depends_on = [ oci_core_vcn.vcn ]
}

resource "oci_core_internet_gateway" "internet_gateway" {
  for_each       = var.subnets
  
  compartment_id = var.provider_id
  vcn_id         = oci_core_vcn.vcn[each.key].id
  
  display_name   = "${each.key}-internet-gateway"
  
  freeform_tags = {
    Name = "${each.key}-internet-gateway"
  }
}

resource "oci_core_nat_gateway" "nat_gateway" {
  for_each       = var.subnets
  
  compartment_id = var.provider_id
  vcn_id         = oci_core_vcn.vcn[each.key].id
  
  display_name   = "${each.key}-nat-gateway"
  
  freeform_tags = {
    Name = "${each.key}-nat-gateway"
  }
  depends_on = [oci_core_internet_gateway.internet_gateway, oci_core_subnet.public_subnets]
}

resource "oci_core_route_table" "public_route_table" {
  for_each       = var.subnets
  
  compartment_id = var.provider_id
  vcn_id         = oci_core_vcn.vcn[each.key].id
  
  display_name   = "${each.key}-public-route-table"
  
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway[each.key].id
  }

  freeform_tags = {
    Name = "${each.key}-public-route-table"
  }
  depends_on = [ oci_core_internet_gateway.internet_gateway ]
}

resource "oci_core_route_table" "private_route_table" {
  for_each       = local.private_subnet_map
  
  compartment_id = var.provider_id
  vcn_id         = each.value.vcn_id
  
  display_name   = "${each.key}-private-route-table"
  
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway[split("-", each.key)[0]].id
  }

  freeform_tags = {
    Name = "${each.key}-private-route-table"
  }

  depends_on = [ oci_core_nat_gateway.nat_gateway , oci_core_internet_gateway.internet_gateway ]
}

resource "oci_core_route_table" "db_route_table" {
  for_each       = local.db_subnet_map
  
  compartment_id = var.provider_id
  vcn_id         = each.value.vcn_id
  
  display_name   = "${each.key}-db-route-table"
  
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway[split("-", each.key)[0]].id
  }

  freeform_tags = {
    Name = "${each.key}-db-route-table"
  }
  
  depends_on = [ oci_core_nat_gateway.nat_gateway , oci_core_internet_gateway.internet_gateway ]
}

