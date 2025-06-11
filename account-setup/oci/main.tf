locals {
    public_subnet_map = merge([
    for vcn_name in keys(var.subnets) : tomap({
      "${vcn_name}-k8sapi" = {
        vcn_id = oci_core_vcn.vcn[vcn_name].id
        subnet = var.subnets[vcn_name].public_subnets_cidr[0]
        compartment_id = var.provider_id
      },
      "${vcn_name}-svclb" = {
        vcn_id = oci_core_vcn.vcn[vcn_name].id
        subnet = var.subnets[vcn_name].public_subnets_cidr[1]
        compartment_id = var.provider_id
      }
    })
  ]...)

  private_subnet_map = merge([
    for vcn_name in keys(var.subnets) : tomap({
      "${vcn_name}-node" = {
        vcn_id = oci_core_vcn.vcn[vcn_name].id
        subnet = var.subnets[vcn_name].private_subnets_cidr[0]
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

  osn_service_id = [for s in data.oci_core_services.all_services.services : s.id if s.cidr_block == "all-bom-services-in-oracle-services-network"][0]
}

resource "oci_core_vcn" "vcn" {
  for_each       = var.subnets
  
  compartment_id = var.provider_id
  cidr_blocks    = [each.value.vpc_cidr]
  
  display_name   = "${each.key}-vcn"
  dns_label      = "okevcn"
  
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
  
  route_table_id = oci_core_route_table.public_route_table[regex("^(.*)-[^-]+$", each.key)[0]].id
  
  prohibit_public_ip_on_vnic = false

  security_list_ids = [
    can(regex("k8sapi", each.key)) 
    ? oci_core_security_list.k8sapi_subnet_security[each.key].id 
    : oci_core_security_list.svclb_subnet_security[each.key].id
  ]  

  freeform_tags = {
    Environment = regex(".*-(.*)", each.key)[0]  
    Name        = "${each.key}-public-subnet"
    Type        = "Public"
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

  security_list_ids = [oci_core_security_list.private_subnet_security[each.key].id ]
  
  freeform_tags = {
    Environment = regex(".*-(.*)", each.key)[0]  
    Name        = "${each.key}-private-subnet"
    Type        = "Private"
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

  security_list_ids = [oci_core_security_list.db_subnet_security[each.key].id]
  
  freeform_tags = {
    Environment = each.key
    Name        = "${each.key}-db-subnet"
    Type        = "DB"
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

resource "oci_core_service_gateway" "service_gateway" {
  for_each       = var.subnets
  
  compartment_id = var.provider_id
  vcn_id         = oci_core_vcn.vcn[each.key].id
  
  display_name   = "${each.key}-service-gateway"

  services {
    service_id = local.osn_service_id
  }

  freeform_tags = {
    Name = "${each.key}-service-gateway"
  }
  
  depends_on = [oci_core_vcn.vcn, oci_core_internet_gateway.internet_gateway]
}


data "oci_core_services" "all_services" {}

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
    network_entity_id = oci_core_nat_gateway.nat_gateway[regex("^(.*)-[^-]+$", each.key)[0]].id
  }

  route_rules {
    destination       = data.oci_core_services.all_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.service_gateway[regex("^(.*)-[^-]+$", each.key)[0]].id
  }

  freeform_tags = {
    Name = "${each.key}-private-route-table"
  }

  depends_on = [ 
    oci_core_nat_gateway.nat_gateway, 
    oci_core_internet_gateway.internet_gateway,
    oci_core_service_gateway.service_gateway
  ]
}

resource "oci_core_route_table" "db_route_table" {
  for_each       = local.db_subnet_map
  
  compartment_id = var.provider_id
  vcn_id         = each.value.vcn_id
  
  display_name   = "${each.key}-db-route-table"
  
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway[regex("^(.*)-[^-]+$", each.key)[0]].id
  }

  route_rules {
    destination       = data.oci_core_services.all_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.service_gateway[regex("^(.*)-[^-]+$", each.key)[0]].id
  }

  freeform_tags = {
    Name = "${each.key}-db-route-table"
  }
  
  depends_on = [ 
    oci_core_nat_gateway.nat_gateway, 
    oci_core_internet_gateway.internet_gateway,
    oci_core_service_gateway.service_gateway
  ]
}

resource "oci_core_security_list" "k8sapi_subnet_security" {
  
  for_each = length(local.public_subnet_map) > 0 ? {
    (keys(local.public_subnet_map)[0]) = values(local.public_subnet_map)[0]
  } : {}
    
  compartment_id = var.provider_id
  vcn_id         = each.value.vcn_id
  display_name   = "${each.key}-security"

  lifecycle {
    ignore_changes = [ ingress_security_rules, egress_security_rules ]
  }
  
  ingress_security_rules {
    protocol    = "6" 
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol    = "6" 
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 12250
      max = 12250
    }
  }

  ingress_security_rules {
    protocol    = "1" 
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol    = "6" 
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    protocol    = "6" 
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    tcp_options {
      min = 1
      max = 65535
    }
  }

  egress_security_rules {
    protocol    = "1" 
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      type = 3
      code = 4
    }
  }
}

resource "oci_core_security_list" "svclb_subnet_security" {
  
  for_each = length(local.public_subnet_map) > 0 ? {
    (keys(local.public_subnet_map)[1]) = values(local.public_subnet_map)[1]
  } : {}
    
  compartment_id = var.provider_id
  vcn_id         = each.value.vcn_id
  display_name   = "${each.key}-security"

  lifecycle {
    ignore_changes = [ ingress_security_rules, egress_security_rules ]
  }
}

resource "oci_core_security_list" "private_subnet_security" {
  for_each       = local.private_subnet_map
  compartment_id = var.provider_id
  vcn_id         = each.value.vcn_id
  display_name   = "${each.key}-security"

  lifecycle {
    ignore_changes = [ ingress_security_rules, egress_security_rules ]
  }

  ingress_security_rules {
    protocol    = "all" 
    source      = each.value.subnet
    source_type = "CIDR_BLOCK"
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
  }

  ingress_security_rules {
    protocol    = "1" 
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    icmp_options {
      type = 3
      code = 4
    }
    description = "Allow ICMP traffic for Path Discovery"
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 1
      max = 65535
    }
    description = "Allow TCP access from Kubernetes Control Plane"
  }

  ingress_security_rules {
    protocol    = "6" 
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 22
      max = 22
    }
    description = "Inbound SSH traffic to worker nodes"
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description = "Allow all outbound traffic"
  }
}

resource "oci_core_security_list" "db_subnet_security" {
  for_each       = local.db_subnet_map
  compartment_id = var.provider_id
  vcn_id         = each.value.vcn_id
  display_name   = "${each.key}-db-security"

  lifecycle {
    ignore_changes = [ ingress_security_rules, egress_security_rules ]
  }

  ingress_security_rules {
    protocol    = "6" 
    source      = [for s in local.private_subnet_map : s.subnet if s.vcn_id == each.value.vcn_id][0]
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 3306
      max = 3306
    }
    description = "Allow MySQL traffic from Kubernetes nodes"
  }

  ingress_security_rules {
    protocol    = "6" 
    source      = [for s in local.private_subnet_map : s.subnet if s.vcn_id == each.value.vcn_id][0]
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 5432
      max = 5432
    }
    description = "Allow PSQL traffic from Kubernetes nodes"
  }
  
  ingress_security_rules {
    protocol    = "6"  
    source      = [for s in local.private_subnet_map : s.subnet if s.vcn_id == each.value.vcn_id][0]
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 6379
      max = 6379
    }
    description = "Allow Redis traffic from Kubernetes nodes"
  }

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "Allow all outbound traffic"
  }
}