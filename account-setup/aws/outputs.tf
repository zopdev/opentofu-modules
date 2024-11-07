output "vpc_id" {
  value = ["${aws_vpc.vpc}"]
}

output "public_subnets" {
  value = [for subnet in aws_subnet.public_subnets : subnet.id]
}

output "private_subnets" {
  value = [for subnet in aws_subnet.private_subnets : subnet.id]
}

output "db_subnets" {
  value = [for subnet in aws_subnet.db_subnets : subnet.id]
}

output "private_cidrs" {
  value = [for subnet in aws_subnet.private_subnets : subnet.cidr_block]
}