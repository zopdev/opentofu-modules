data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  count               = var.vnet != "" ? 1 : 0
  name                = var.vnet
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = var.address_space
}

# Public subnet for NAT Gateway
resource "azurerm_subnet" "public" {
  count                = var.vnet != "" && var.create_nat_gateway ? 1 : 0
  name                 = "${var.vnet}-public-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = var.public_subnet_cidr
}

# Public IP for NAT Gateway
resource "azurerm_public_ip" "nat_gateway_ip" {
  count               = var.vnet != "" && var.create_nat_gateway ? 1 : 0
  name                = "${var.vnet}-nat-gateway-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = {
    Name = "${var.vnet}-nat-gateway-pip"
  }
}

# NAT Gateway for private subnet outbound connectivity
resource "azurerm_nat_gateway" "nat_gateway" {
  count               = var.vnet != "" && var.create_nat_gateway ? 1 : 0
  name                = "${var.vnet}-nat-gateway"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku_name            = "Standard"
  idle_timeout_in_minutes = 10
  
  tags = {
    Name = "${var.vnet}-nat-gateway"
  }
}

# Associate Public IP with NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_ip_assoc" {
  count               = var.vnet != "" && var.create_nat_gateway ? 1 : 0
  nat_gateway_id      = azurerm_nat_gateway.nat_gateway[0].id
  public_ip_address_id = azurerm_public_ip.nat_gateway_ip[0].id
}

# Private subnet for AKS nodes and other services (like AWS/GCP pattern)
resource "azurerm_subnet" "private" {
  count                = var.vnet != "" && var.create_private_subnet ? 1 : 0
  name                 = "${var.vnet}-private-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = var.private_subnet_cidr
}

# Associate NAT Gateway with private subnet (for outbound connectivity)
resource "azurerm_subnet_nat_gateway_association" "private_nat" {
  count         = var.vnet != "" && var.create_private_subnet && var.create_nat_gateway ? 1 : 0
  subnet_id     = azurerm_subnet.private[0].id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway[0].id
}

# Network Security Group for private subnet - allow all internal VNet communication
resource "azurerm_network_security_group" "private" {
  count               = var.vnet != "" && var.create_private_subnet ? 1 : 0
  name                = "${var.vnet}-private-nsg"
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
    Name = "${var.vnet}-private-nsg"
  }
}

# Associate NSG with private subnet
resource "azurerm_subnet_network_security_group_association" "private" {
  count                     = var.vnet != "" && var.create_private_subnet ? 1 : 0
  subnet_id                 = azurerm_subnet.private[0].id
  network_security_group_id = azurerm_network_security_group.private[0].id
}

# Subnet for databases (MySQL, PostgreSQL) - like AWS db_subnets
resource "azurerm_subnet" "database" {
  count                = var.vnet != "" && var.create_database_subnet ? 1 : 0
  name                 = "${var.vnet}-database-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = var.database_subnet_cidr
  
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
  count               = var.vnet != "" && var.create_database_subnet && var.create_private_subnet ? 1 : 0
  name                = "${var.vnet}-database-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  # Allow MySQL (3306) from private subnet only
  security_rule {
    name                       = "AllowMySQLFromPrivateSubnet"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = var.private_subnet_cidr[0]
    destination_address_prefix = "*"
    description                = "Allow MySQL traffic from AKS cluster (private subnet)"
  }

  # Allow PostgreSQL (5432) from private subnet only
  security_rule {
    name                       = "AllowPostgreSQLFromPrivateSubnet"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = var.private_subnet_cidr[0]
    destination_address_prefix = "*"
    description                = "Allow PostgreSQL traffic from AKS cluster (private subnet)"
  }

  # Allow Redis (6379) from private subnet only
  security_rule {
    name                       = "AllowRedisFromPrivateSubnet"
    priority                   = 1200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6379"
    source_address_prefix      = var.private_subnet_cidr[0]
    destination_address_prefix = "*"
    description                = "Allow Redis traffic from AKS cluster (private subnet)"
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
    Name = "${var.vnet}-database-nsg"
  }
}

# Associate NSG with database subnet
resource "azurerm_subnet_network_security_group_association" "database" {
  count                     = var.vnet != "" && var.create_database_subnet && var.create_private_subnet ? 1 : 0
  subnet_id                 = azurerm_subnet.database[0].id
  network_security_group_id = azurerm_network_security_group.database[0].id
}