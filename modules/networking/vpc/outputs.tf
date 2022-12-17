# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = module.vpc.name
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "azs" {
  description = "The list of eligible AZs for provisioning the VPC subnets"
  value       = module.vpc.azs
}

output "private_subnets" {
  description = "The list of the VPC private subnet IDs"
  value       = module.vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
  description = "The list of the VPC private subnet CIDRs"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets" {
  description = "The list of the VPC public subnet IDs"
  value       = module.vpc.public_subnets
}

output "public_subnets_cidr_blocks" {
  description = "The list of the VPC public subnet CIDRs"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "private_route_table_ids" {
  description = "The IDs of the private route tables"
  value       = module.vpc.private_route_table_ids
}

output "public_route_table_ids" {
  description = "The IDs of the public route tables"
  value       = module.vpc.public_route_table_ids
}

output "nat_gateway_ids" {
  description = "The IDs of the NAT Gateways"
  value       = module.vpc.natgw_ids
}
