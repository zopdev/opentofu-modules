data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

locals {
  # Public subnet CIDR - default to first /24 if not provided (for NAT Gateway)
  public_subnet_cidrs = {
    for vnet_name, vnet_config in var.vnet_config : vnet_name => length(try(vnet_config.public_subnets_cidr, [])) > 0 ? vnet_config.public_subnets_cidr : [cidrsubnet(vnet_config.address_space[0], 8, 0)]
  }
  
  # Default public subnet CIDR if not provided (for NAT Gateway)
  public_subnet_map = merge([
    for vnet_name, vnet_config in var.vnet_config : tomap({
      for idx, cidr in local.public_subnet_cidrs[vnet_name] :
        "${vnet_name}-${idx}" => {
          vnet_name = vnet_name
          cidr      = cidr
        }
    })
  ]...)

  # Private subnets
  private_subnet_map = merge([
    for vnet_name, vnet_config in var.vnet_config : tomap({
      for idx, cidr in vnet_config.private_subnets_cidr :
        "${vnet_name}-${idx}" => {
          vnet_name = vnet_name
          cidr      = cidr
        }
    })
  ]...)

  # Database subnets
  database_subnet_map = merge([
    for vnet_name, vnet_config in var.vnet_config : tomap({
      for idx, cidr in try(vnet_config.database_subnets_cidr, []) :
        "${vnet_name}-${idx}" => {
          vnet_name = vnet_name
          cidr      = cidr
        }
    })
  ]...)
}

resource "azurerm_virtual_network" "vnet" {
  for_each            = var.vnet_config
  name                = each.key
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = each.value.address_space
}

# Public subnet for NAT Gateway (auto-created if private subnets exist, like GCP)
resource "azurerm_subnet" "public" {
  for_each             = local.public_subnet_map
  name                 = "${each.value.vnet_name}-public-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_name].name
  address_prefixes     = [each.value.cidr]
}

# Public IP for NAT Gateway (auto-created like GCP)
resource "azurerm_public_ip" "nat_gateway_ip" {
  for_each            = var.vnet_config
  name                = "${each.key}-nat-gateway-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = {
    Name = "${each.key}-nat-gateway-pip"
  }
}

# NAT Gateway for private subnet outbound connectivity (auto-created like GCP)
resource "azurerm_nat_gateway" "nat_gateway" {
  for_each                = var.vnet_config
  name                    = "${each.key}-nat-gateway"
  location                = data.azurerm_resource_group.rg.location
  resource_group_name     = data.azurerm_resource_group.rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  
  tags = {
    Name = "${each.key}-nat-gateway"
  }
}

# Associate Public IP with NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_ip_assoc" {
  for_each            = var.vnet_config
  nat_gateway_id      = azurerm_nat_gateway.nat_gateway[each.key].id
  public_ip_address_id = azurerm_public_ip.nat_gateway_ip[each.key].id
}

# Private subnet for AKS nodes and other services (like AWS/GCP pattern)
resource "azurerm_subnet" "private" {
  for_each             = local.private_subnet_map
  name                 = "${each.value.vnet_name}-private-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_name].name
  address_prefixes     = [each.value.cidr]
}

# Associate NAT Gateway with private subnet (for outbound connectivity)
resource "azurerm_subnet_nat_gateway_association" "private_nat" {
  for_each       = local.private_subnet_map
  subnet_id      = azurerm_subnet.private[each.key].id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway[each.value.vnet_name].id
}

# Network Security Group for private subnet - allow all internal VNet communication
resource "azurerm_network_security_group" "private" {
  for_each            = var.vnet_config
  name                = "${each.key}-private-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  # Allow all traffic within VNet (default Azure behavior, but explicit)
  security_rule {
    name                       = "AllowVNetInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  # Allow all outbound (for NAT Gateway to work)
  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 2000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name = "${each.key}-private-nsg"
  }
}

# Associate NSG with private subnet
resource "azurerm_subnet_network_security_group_association" "private" {
  for_each                  = local.private_subnet_map
  subnet_id                 = azurerm_subnet.private[each.key].id
  network_security_group_id = azurerm_network_security_group.private[each.value.vnet_name].id
}

# Subnet for databases (MySQL, PostgreSQL) - like AWS db_subnets
resource "azurerm_subnet" "database" {
  for_each             = local.database_subnet_map
  name                 = "${each.value.vnet_name}-database-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_name].name
  address_prefixes     = [each.value.cidr]
  
  delegation {
    name = "database-delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Network Security Group for database subnet - ONLY allow traffic from private subnet (cluster)
resource "azurerm_network_security_group" "database" {
  for_each            = local.database_subnet_map
  name                = "${each.value.vnet_name}-database-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  # Allow MySQL (3306) from private subnets
  dynamic "security_rule" {
    for_each = var.vnet_config[each.value.vnet_name].private_subnets_cidr
    content {
      name                       = "AllowMySQLFromPrivateSubnet-${security_rule.key}"
      priority                   = 1000 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3306"
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
      description                = "Allow MySQL traffic from AKS cluster (private subnet)"
    }
  }

  # Allow PostgreSQL (5432) from private subnets
  dynamic "security_rule" {
    for_each = var.vnet_config[each.value.vnet_name].private_subnets_cidr
    content {
      name                       = "AllowPostgreSQLFromPrivateSubnet-${security_rule.key}"
      priority                   = 1100 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "5432"
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
      description                = "Allow PostgreSQL traffic from AKS cluster (private subnet)"
    }
  }

  # Allow Redis (6379) from private subnets
  dynamic "security_rule" {
    for_each = var.vnet_config[each.value.vnet_name].private_subnets_cidr
    content {
      name                       = "AllowRedisFromPrivateSubnet-${security_rule.key}"
      priority                   = 1200 + security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "6379"
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
      description                = "Allow Redis traffic from AKS cluster (private subnet)"
    }
  }

  # Deny all other inbound traffic (Azure default, but explicit)
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Deny all other inbound traffic"
  }

  # Allow all outbound (for database connections back to cluster if needed)
  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 2000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name = "${each.value.vnet_name}-database-nsg"
  }
}

# Associate NSG with database subnet
resource "azurerm_subnet_network_security_group_association" "database" {
  for_each                  = local.database_subnet_map
  subnet_id                 = azurerm_subnet.database[each.key].id
  network_security_group_id = azurerm_network_security_group.database[each.key].id
}