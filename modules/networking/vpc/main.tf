# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  vpc_name = var.environment

  default_resources_name = format("%s-default", local.vpc_name)

  public_subnet_cidrs = [
    cidrsubnet(var.cidr, 5, 0), # e.g. 10.0.0.0/21
    cidrsubnet(var.cidr, 5, 1), # e.g. 10.0.8.0/21
    cidrsubnet(var.cidr, 5, 2), # e.g. 10.0.16.0/21
    # cidrsubnet(var.cidr, 5, 3), # e.g. 10.0.24.0/21 - reserved for future use
    # cidrsubnet(var.cidr, 5, 4), # e.g. 10.0.32.0/21 - reserved for future use
  ]

  private_subnet_cidrs = [
    cidrsubnet(var.cidr, 5, 5), # e.g. 10.0.40.0/21
    cidrsubnet(var.cidr, 5, 6), # e.g. 10.0.48.0/21
    cidrsubnet(var.cidr, 5, 7), # e.g. 10.0.56.0/21
    # cidrsubnet(var.cidr, 5, 8), # e.g. 10.0.64.0/21 - reserved for future use
    # cidrsubnet(var.cidr, 5, 9), # e.g. 10.0.72.0/21 - reserved for future use
  ]

  database_subnet_cidrs = [
    cidrsubnet(var.cidr, 5, 10), # e.g. 10.0.80.0/21
    cidrsubnet(var.cidr, 5, 11), # e.g. 10.0.88.0/21
    cidrsubnet(var.cidr, 5, 12), # e.g. 10.0.96.0/21
    # cidrsubnet(var.cidr, 5, 13), # e.g. 10.0.104.0/21 - reserved for future use
    # cidrsubnet(var.cidr, 5, 14), # e.g. 10.0.112.0/21 - reserved for future use
  ]

  elasticache_subnet_cidrs = [
    cidrsubnet(var.cidr, 5, 15), # e.g. 10.0.80.0/21
    cidrsubnet(var.cidr, 5, 16), # e.g. 10.0.88.0/21
    cidrsubnet(var.cidr, 5, 17), # e.g. 10.0.96.0/21
    # cidrsubnet(var.cidr, 5, 18), # e.g. 10.0.104.0/21 - reserved for future use
    # cidrsubnet(var.cidr, 5, 19), # e.g. 10.0.112.0/21 - reserved for future use
  ]
}

# ------------------------------------------------------------------------------
# TAGS
# ------------------------------------------------------------------------------

module "tags" {
  source  = "flaudisio/standard-tags/aws"
  version = "0.3.0"

  environment = var.environment
  owner       = "infra"
  service     = "core-infra"
}

# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"

  # Some AZs have datacenter or instance type limitations and should not be used.
  # They can all be included in this same list, even for different regions.
  #
  # !!! WARNING !!!
  #
  # Changing this list may trigger the *DESTRUCTION* of subnets on VPCs already
  # provisioned in the affected regions!
  #
  # CHANGE ONLY IF YOU KNOW WHAT YOU ARE DOING AND AFTER *THOROUGHLY* TESTING!
  exclude_names = [
    "us-east-1e",
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = local.vpc_name

  cidr = var.cidr

  # NOTE: the number of AZs *must* be less than or equal the number of public subnets
  # Ref: https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/v3.18.1/main.tf#L360
  azs = slice(sort(data.aws_availability_zones.available.names), 0, length(local.public_subnet_cidrs))

  public_subnets      = local.public_subnet_cidrs
  private_subnets     = local.private_subnet_cidrs
  database_subnets    = local.database_subnet_cidrs
  elasticache_subnets = local.elasticache_subnet_cidrs

  # NAT Gateway
  # See https://github.com/terraform-aws-modules/terraform-aws-vpc#nat-gateway-scenarios
  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  # Default resources
  manage_default_security_group = true
  manage_default_route_table    = true
  manage_default_network_acl    = true
  manage_default_vpc            = false

  default_security_group_name = local.default_resources_name
  default_route_table_name    = local.default_resources_name
  default_network_acl_name    = local.default_resources_name

  # DNS settings to allow using private Route 53 zones
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Subnet groups
  create_database_subnet_group    = true
  create_elasticache_subnet_group = true

  tags = module.tags.tags
}
