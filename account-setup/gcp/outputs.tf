output "vpc" {
  value = tomap(
    {
    for k, v in var.vpc_config : k=> google_compute_network.vpc_config[k].self_link
    } )
}


output "private_subnets" {
  value = [for subnet in google_compute_subnetwork.subnet_config : subnet.name]
}