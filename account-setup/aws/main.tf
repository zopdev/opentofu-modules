locals {
  public_subnet_map = merge([
    for vpc_name in keys(var.subnets) : tomap({
      for subnet in var.subnets[vpc_name].public_subnets_cidr : "${vpc_name}-${subnet}" => {
        vpc_id = aws_vpc.vpc[vpc_name].id
        subnet = subnet
        az = var.subnets[vpc_name].availability_zones[index(var.subnets[vpc_name].public_subnets_cidr,subnet)]
      }
    })
  ]
    ...)
  private_subnet_map = merge([
    for vpc_name in keys(var.subnets) : tomap({
      for subnet in var.subnets[vpc_name].private_subnets_cidr : "${vpc_name}-${subnet}" => {
        vpc_id = aws_vpc.vpc[vpc_name].id
        subnet = subnet
        az = var.subnets[vpc_name].availability_zones[index(var.subnets[vpc_name].private_subnets_cidr,subnet)]
      }
    })
  ]
    ...)
  db_subnet_map = merge([
    for vpc_name in keys(var.subnets) : tomap({
      for subnet in var.subnets[vpc_name].db_subnets_cidr : "${vpc_name}-${subnet}" => {
        vpc_id = aws_vpc.vpc[vpc_name].id
        subnet = subnet
        az = var.subnets[vpc_name].availability_zones[index(var.subnets[vpc_name].db_subnets_cidr,subnet)]
      }
    })
  ]
    ...)

}

resource "aws_vpc" "vpc" {
  for_each             = var.subnets
  cidr_block           = each.value.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${each.key}-vpc"
    Environment = each.key
    Provisioner = var.provisioner
  }
}

resource "aws_subnet" "public_subnets" {
  for_each                = local.public_subnet_map
  vpc_id                  = each.value["vpc_id"]
  cidr_block              = each.value["subnet"]
  availability_zone = each.value["az"]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${each.key}-public-subnet"
    Environment = "${each.key}"
    Provisioner = var.provisioner
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_subnet" "private_subnets" {
  for_each                = local.private_subnet_map
  vpc_id                  = each.value["vpc_id"]
  cidr_block              = each.value["subnet"]
  availability_zone = each.value["az"]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${each.key}-private-subnet"
    Environment = "${each.key}"
    Provisioner = var.provisioner
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_subnet" "db_subnets" {
  for_each                = local.db_subnet_map
  vpc_id                  = each.value["vpc_id"]
  cidr_block              = each.value["subnet"]
  availability_zone = each.value["az"]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${each.key}-db-subnet"
    Environment = "${each.key}"
    Provisioner = var.provisioner
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_internet_gateway" "internet_gw" {
  for_each = var.subnets
  vpc_id                  = aws_vpc.vpc[each.key].id

  tags = {
    Name = "${each.key}-internet-gw"
    Provisioner = var.provisioner
  }
}

## Route table
resource "aws_route_table" "public_route_table" {
  for_each = var.subnets
  vpc_id              = aws_vpc.vpc[each.key].id

  tags = {
    Name = "${each.key}-public_route_table"
    Provisioner = var.provisioner
  }
}

resource "aws_route_table" "private_route_table" {
  for_each            = local.private_subnet_map
  vpc_id              = aws_vpc.vpc[split("-",each.key)[0]].id

  tags = {
    Name = "${each.key}-private_route_table"
    Provisioner = var.provisioner
  }
}

resource "aws_route_table" "db_route_table" {
  for_each            = local.db_subnet_map
  vpc_id              = aws_vpc.vpc[split("-",each.key)[0]].id

  tags = {
    Name = "${each.key}-db_route_table"
    Provisioner = var.provisioner
  }
}

resource "aws_eip" "eip" {
  for_each = local.public_subnet_map
  vpc      = true
  depends_on = [aws_internet_gateway.internet_gw]
  tags = {
    Name = "${each.key}-nat-gateway-eip"
    Provisioner = var.provisioner
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  for_each = local.public_subnet_map
  allocation_id = aws_eip.eip[each.key].id
  subnet_id     = aws_subnet.public_subnets[each.key].id
  tags = {
    Name = "${each.key}-nat-gateway-public"
    Provisioner = var.provisioner
  }

  depends_on = [aws_eip.eip,aws_subnet.public_subnets,aws_internet_gateway.internet_gw]
}

resource "aws_route" "public_route" {
  for_each = var.subnets
  route_table_id            = aws_route_table.public_route_table[each.key].id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.internet_gw[each.key].id
  depends_on                = [aws_internet_gateway.internet_gw]
}

resource "aws_route" "private_route" {
  count = length(keys(local.private_subnet_map))
  route_table_id            = aws_route_table.private_route_table[element(keys(local.private_subnet_map),count.index)].id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.nat-gateway[element(keys(local.public_subnet_map),count.index)].id
  depends_on                = [aws_nat_gateway.nat-gateway,aws_internet_gateway.internet_gw]
}

resource "aws_route" "db_route" {
  count = length(keys(local.db_subnet_map))
  route_table_id            = aws_route_table.db_route_table[element(keys(local.db_subnet_map),count.index)].id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.nat-gateway[element(keys(local.public_subnet_map),count.index)].id
  depends_on                = [aws_nat_gateway.nat-gateway,aws_internet_gateway.internet_gw]
}

resource "aws_route_table_association" "public_route_table_association" {
  for_each = local.public_subnet_map
  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.public_route_table[split("-",each.key)[0]].id
}

resource "aws_route_table_association" "private_route_table_association" {
  for_each      = local.private_subnet_map

  subnet_id = aws_subnet.private_subnets[each.key].id
  route_table_id = aws_route_table.private_route_table[each.key].id
}

resource "aws_route_table_association" "db_route_table_association" {
  for_each      = local.db_subnet_map

  subnet_id      = aws_subnet.db_subnets[each.key].id
  route_table_id = aws_route_table.db_route_table[each.key].id
}

resource "aws_security_group" "allow_tls" {
  for_each      = var.subnets
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.vpc[each.key].id
}
