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

output "database_subnets" {
  description = "The list of IDs of the database subnets"
  value       = module.vpc.database_subnets
}

output "database_subnets_cidr_blocks" {
  description = "The list of CIDRs of the database subnets"
  value       = module.vpc.database_subnets_cidr_blocks
}

output "database_subnet_group" {
  description = "The ID of the database subnet group"
  value       = module.vpc.database_subnet_group
}

output "database_subnet_group_name" {
  description = "The name of the database subnet group"
  value       = module.vpc.database_subnet_group_name
}

output "elasticache_subnets" {
  description = "The list of IDs of the ElastiCache subnets"
  value       = module.vpc.elasticache_subnets
}

output "elasticache_subnets_cidr_blocks" {
  description = "The list of CIDRs of the ElastiCache subnets"
  value       = module.vpc.elasticache_subnets_cidr_blocks
}

output "elasticache_subnet_group" {
  description = "The ID of the ElastiCache subnet group"
  value       = module.vpc.elasticache_subnet_group
}

output "elasticache_subnet_group_name" {
  description = "The name of the ElastiCache subnet group"
  value       = module.vpc.elasticache_subnet_group_name
}

output "private_route_table_ids" {
  description = "The list of IDs of the private route tables"
  value       = module.vpc.private_route_table_ids
}

output "private_subnets" {
  description = "The list of IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
  description = "The list of CIDRs of the private subnets"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets" {
  description = "The list of IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "public_subnets_cidr_blocks" {
  description = "The list of CIDRs of public subnets"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "public_route_table_ids" {
  description = "The list of IDs of the public route tables"
  value       = module.vpc.public_route_table_ids
}

output "nat_gateway_ids" {
  description = "The IDs of the NAT Gateways"
  value       = module.vpc.natgw_ids
}
