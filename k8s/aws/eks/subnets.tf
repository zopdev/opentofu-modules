locals {
  ext_rds_sg_cidr_block = concat([data.aws_vpc.vpc.cidr_block], var.ext_rds_sg_cidr_block)

  vpc_id               = data.aws_subnet.private_cidrs.vpc_id
  subnet_cidrs         =   concat(local.db_subnets_cidrs,local.private_subnet_cidrs)
  private_subnet_cidrs =  [ for subnet in  data.aws_subnet.private_subnet_cidrs : subnet.cidr_block]
  db_subnets_cidrs     =  [ for subnet in  data.aws_subnet.db_subnet_cidrs : subnet.cidr_block]
  private_subnet_ids   = [ for subnet in  data.aws_subnet.private_subnet_cidrs : subnet.id]
}

data "aws_subnet" "private_cidrs" {
  filter {
    name   = "tag:Name"
    values = [var.subnets.private_subnets[0]]
  }
}

data "aws_vpc" "vpc" {
  id = local.vpc_id
}

data "aws_subnet" "private_subnet_cidrs" {
  for_each = toset(var.subnets.private_subnets)
  filter {
    name   = "tag:Name"
    values = [each.value]
  }
}

data "aws_subnet" "public_subnet_cidrs" {
  for_each = toset(var.subnets.public_subnets)
  filter {
    name   = "tag:Name"
    values = [each.value]
  }
}

data "aws_subnet" "db_subnet_cidrs" {
  for_each = toset(var.subnets.db_subnets)
  filter {
    name   = "tag:Name"
    values = [each.value]
  }
}