# ------------------------------------------------------------------------------
# TAGS
# ------------------------------------------------------------------------------

module "tags" {
  source  = "flaudisio/standard-tags/aws"
  version = "0.3.0"

  environment = var.environment
  owner       = var.owner
  service     = var.cluster_name
}

# ------------------------------------------------------------------------------
# CLUSTER KEY PAIR
# ------------------------------------------------------------------------------

resource "aws_key_pair" "this" {
  key_name   = var.cluster_name
  public_key = var.cluster_public_key

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# CLUSTER SECURITY GROUP
# ------------------------------------------------------------------------------

module "cluster_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name        = format("%s-intra", var.cluster_name)
  description = "${var.cluster_name} - Cluster intra communication"
  vpc_id      = var.vpc_id

  ingress_with_self = [
    {
      rule        = "all-all"
      description = "Self"
    },
  ]

  ingress_with_cidr_blocks = var.allow_vpc_access ? [
    {
      rule        = "all-all"
      description = "Access from VPC"
      cidr_blocks = var.vpc_cidr_block
    },
  ] : []

  egress_rules = ["all-all"]

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# SERVER INSTANCES
# ------------------------------------------------------------------------------

module "server_instances" {
  source = "./modules/instances"

  environment = var.environment

  private_subnets = var.private_subnets

  key_name        = aws_key_pair.this.key_name
  security_groups = concat([module.cluster_security_group.security_group_id], var.attach_security_groups)

  owner = var.owner

  service_name = format("%s-servers", var.cluster_name)
  service_role = "nomad-server"

  ami_name         = var.server_ami_name
  ami_owner        = var.server_ami_owner
  ami_architecture = var.server_ami_architecture

  instance_type    = var.server_instance_type
  instance_count   = var.server_instance_count
  root_volume_size = var.server_root_volume_size
}

# ------------------------------------------------------------------------------
# CLIENT INSTANCES
# ------------------------------------------------------------------------------

module "client_instances" {
  source = "./modules/instances"

  for_each = var.client_instance_groups

  environment = var.environment

  private_subnets = var.private_subnets

  key_name        = aws_key_pair.this.key_name
  security_groups = concat([module.cluster_security_group.security_group_id], var.attach_security_groups)

  owner = var.owner

  service_name = format("%s-clients-%s", var.cluster_name, each.key)
  service_role = "nomad-client"

  ami_name         = each.value.ami_name
  ami_owner        = each.value.ami_owner
  ami_architecture = each.value.architecture

  instance_type    = each.value.instance_type
  instance_count   = each.value.instance_count
  root_volume_size = each.value.root_volume_size
}
