data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

locals {
  # Constants for NSG rule priorities
  nsg_priority_base_vnet_inbound        = 1000
  nsg_priority_base_loadbalancer        = 1050
  nsg_priority_base_http                = 1100
  nsg_priority_base_https               = 1200
  nsg_priority_base_outbound            = 2000
  nsg_priority_base_database_allow      = 1000
  nsg_priority_increment_per_subnet     = 10  # Prevents conflicts with multiple subnets
  nsg_priority_deny_all                 = 4000
  
  # Database port constants
  postgresql_port = 5432
  mysql_port      = 3306

  private_subnet_map = merge([
    for vnet_name, vnet_config in var.vnet_config : tomap({
      for idx, cidr in vnet_config.private_subnets_cidr :
        "${vnet_name}-${idx}" => {
          vnet_name = vnet_name
          cidr      = cidr
        }
    })
  ]...)

  # Database subnets - Azure doesn't allow MySQL and PostgreSQL delegations on the same subnet
  # 
  # Subnet allocation pattern:
  #   - PostgreSQL uses even indices (0, 2, 4, 6...)
  #   - MySQL uses odd indices (1, 3, 5, 7...)
  # 
  # Example configuration:
  #   database_subnets_cidr = ["10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
  #   Results in:
  #     - Index 0 (10.0.2.0/24) -> PostgreSQL subnet: ${vnet_name}-postgresql-subnet
  #     - Index 1 (10.0.3.0/24) -> MySQL subnet: ${vnet_name}-mysql-subnet
  #     - Index 2 (10.0.4.0/24) -> PostgreSQL subnet: ${vnet_name}-postgresql-subnet
  #     - Index 3 (10.0.5.0/24) -> MySQL subnet: ${vnet_name}-mysql-subnet
  postgresql_subnet_map = merge([
    for vnet_name, vnet_config in var.vnet_config : tomap({
      for idx, cidr in try(vnet_config.database_subnets_cidr, []) :
        "${vnet_name}-postgres-${idx}" => {
          vnet_name = vnet_name
          cidr      = cidr
          idx       = idx
        } if idx % 2 == 0
    })
  ]...)
  
  mysql_subnet_map = merge([
    for vnet_name, vnet_config in var.vnet_config : tomap({
      for idx, cidr in try(vnet_config.database_subnets_cidr, []) :
        "${vnet_name}-mysql-${idx}" => {
          vnet_name = vnet_name
          cidr      = cidr
          idx       = idx
        } if idx % 2 == 1
    })
  ]...)
  
  # Combined database subnet map for outputs (backwards compatibility)
  database_subnet_map = merge(local.postgresql_subnet_map, local.mysql_subnet_map)
}

resource "azurerm_virtual_network" "vnet" {
  for_each            = var.vnet_config
  name                = each.key
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = each.value.address_space
}

# Subnet for AKS nodes (nodes will have public IPs for internet access)
resource "azurerm_subnet" "private" {
  for_each             = local.private_subnet_map
  name                 = "${each.value.vnet_name}-private-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_name].name
  address_prefixes     = [each.value.cidr]
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
    priority                   = local.nsg_priority_base_vnet_inbound
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  # Allow Azure LoadBalancer health probes (required for LoadBalancer services)
  security_rule {
    name                       = "AllowAzureLoadBalancerInbound"
    priority                   = local.nsg_priority_base_loadbalancer
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
    description                = "Allow Azure LoadBalancer health probes and traffic"
  }

  # Allow HTTP (80) from internet for ingress LoadBalancer
  security_rule {
    name                       = "AllowHTTPInbound"
    priority                   = local.nsg_priority_base_http
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow HTTP traffic from internet for ingress LoadBalancer"
  }

  # Allow HTTPS (443) from internet for ingress LoadBalancer
  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = local.nsg_priority_base_https
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow HTTPS traffic from internet for ingress LoadBalancer"
  }

  # Allow all outbound (nodes have public IPs for direct internet access)
  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = local.nsg_priority_base_outbound
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

# Subnet for PostgreSQL databases - Azure requires separate subnet per service delegation
resource "azurerm_subnet" "postgresql" {
  for_each             = local.postgresql_subnet_map
  name                 = "${each.value.vnet_name}-postgresql-subnet"
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

# Subnet for MySQL databases - Azure requires separate subnet per service delegation
resource "azurerm_subnet" "mysql" {
  for_each             = local.mysql_subnet_map
  name                 = "${each.value.vnet_name}-mysql-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_name].name
  address_prefixes     = [each.value.cidr]
  
  delegation {
    name = "database-delegation"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Network Security Group for PostgreSQL subnet - ONLY allow traffic from private subnet (cluster)
resource "azurerm_network_security_group" "postgresql" {
  for_each            = local.postgresql_subnet_map
  name                = "${each.value.vnet_name}-postgresql-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  # Allow PostgreSQL from private subnets
  dynamic "security_rule" {
    for_each = var.vnet_config[each.value.vnet_name].private_subnets_cidr
    content {
      name                       = "AllowPostgreSQLFromPrivateSubnet-${security_rule.key}"
      priority                   = local.nsg_priority_base_database_allow + (security_rule.key * local.nsg_priority_increment_per_subnet)
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = tostring(local.postgresql_port)
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
      description                = "Allow PostgreSQL traffic from AKS cluster (private subnet)"
    }
  }

  # Deny all other inbound traffic (Azure default, but explicit)
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = local.nsg_priority_deny_all
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
    priority                   = local.nsg_priority_base_outbound
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name = "${each.value.vnet_name}-postgresql-nsg"
  }
}

# Network Security Group for MySQL subnet - ONLY allow traffic from private subnet (cluster)
resource "azurerm_network_security_group" "mysql" {
  for_each            = local.mysql_subnet_map
  name                = "${each.value.vnet_name}-mysql-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  # Allow MySQL from private subnets
  dynamic "security_rule" {
    for_each = var.vnet_config[each.value.vnet_name].private_subnets_cidr
    content {
      name                       = "AllowMySQLFromPrivateSubnet-${security_rule.key}"
      priority                   = local.nsg_priority_base_database_allow + (security_rule.key * local.nsg_priority_increment_per_subnet)
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = tostring(local.mysql_port)
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
      description                = "Allow MySQL traffic from AKS cluster (private subnet)"
    }
  }

  # Deny all other inbound traffic (Azure default, but explicit)
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = local.nsg_priority_deny_all
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
    priority                   = local.nsg_priority_base_outbound
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name = "${each.value.vnet_name}-mysql-nsg"
  }
}

# Associate NSG with PostgreSQL subnet
resource "azurerm_subnet_network_security_group_association" "postgresql" {
  for_each                  = local.postgresql_subnet_map
  subnet_id                 = azurerm_subnet.postgresql[each.key].id
  network_security_group_id = azurerm_network_security_group.postgresql[each.key].id
}

# Associate NSG with MySQL subnet
resource "azurerm_subnet_network_security_group_association" "mysql" {
  for_each                  = local.mysql_subnet_map
  subnet_id                 = azurerm_subnet.mysql[each.key].id
  network_security_group_id = azurerm_network_security_group.mysql[each.key].id
}
