# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  service_name = "prometheus-server"

  ec2_name_prefix = format("%s-ec2", local.service_name)
}

# ------------------------------------------------------------------------------
# TAGS
# ------------------------------------------------------------------------------

module "tags" {
  source  = "flaudisio/standard-tags/aws"
  version = "0.1.1"

  environment = var.environment
  service     = local.service_name
  owner       = "infra"
}

# ------------------------------------------------------------------------------
# TIMESTREAM DATABASE & TABLE
# ------------------------------------------------------------------------------

resource "aws_timestreamwrite_database" "this" {
  database_name = local.service_name

  tags = module.tags.tags
}

resource "aws_timestreamwrite_table" "this" {
  database_name = aws_timestreamwrite_database.this.database_name

  table_name = local.service_name

  retention_properties {
    magnetic_store_retention_period_in_days = 30
    memory_store_retention_period_in_hours  = 6
  }

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# AMI
# ------------------------------------------------------------------------------

data "aws_ami" "selected" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [var.ami_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = [var.ami_architecture]
  }
}

# ------------------------------------------------------------------------------
# KEY PAIR
# ------------------------------------------------------------------------------

resource "aws_key_pair" "this" {
  key_name   = local.service_name
  public_key = var.public_key

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# IAM POLICY - ASG/EC2 INSTANCES
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "asg_instances" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
    ]
    resources = ["*"]
  }

  # Ref: https://github.com/dpattmann/prometheus-timestream-adapter#aws-policy
  statement {
    effect = "Allow"
    actions = [
      "timestream:Select",
      "timestream:WriteRecords",
    ]
    resources = [aws_timestreamwrite_table.this.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "timestream:DescribeEndpoints",
      "timestream:SelectValues",
    ]
    resources = ["*"]
  }
}

module "asg_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.11.2"

  name        = local.ec2_name_prefix
  description = "Prometheus - EC2 instances - ${local.service_name}"

  policy = data.aws_iam_policy_document.asg_instances.json

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# SECURITY GROUP
# ------------------------------------------------------------------------------

module "asg_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name        = local.ec2_name_prefix
  description = "Prometheus - EC2 instances - ${local.service_name}"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = var.allow_vpc_access ? [
    {
      rule        = "prometheus-http-tcp"
      description = "Access from VPC"
      cidr_blocks = var.vpc_cidr_block
    },
    {
      rule        = "prometheus-pushgateway-http-tcp"
      description = "Access from VPC"
      cidr_blocks = var.vpc_cidr_block
    },
    {
      rule        = "prometheus-node-exporter-http-tcp"
      description = "Access from VPC"
      cidr_blocks = var.vpc_cidr_block
    },
    {
      rule        = "ssh-tcp"
      description = "Access from VPC"
      cidr_blocks = var.vpc_cidr_block
    },
  ] : []

  egress_rules = ["all-all"]

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# AUTO SCALING
# ------------------------------------------------------------------------------

data "aws_default_tags" "current" {}

locals {
  user_data_file = "${path.module}/templates/user_data.sh.tftpl"

  user_data_vars = {
    environment = var.environment
    service     = local.service_name
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.3"

  # Auto scaling group
  name            = local.service_name
  use_name_prefix = false

  min_size         = var.instance_count
  max_size         = var.instance_count
  desired_capacity = var.instance_count

  ignore_desired_capacity_changes = true

  vpc_zone_identifier = var.private_subnets

  health_check_grace_period = 300
  health_check_type         = "EC2"

  termination_policies = [
    "OldestLaunchTemplate",
    "OldestInstance",
    "Default",
  ]

  # Launch template
  launch_template_use_name_prefix = false

  update_default_version = true

  instance_type = var.instance_type
  image_id      = data.aws_ami.selected.id

  key_name  = aws_key_pair.this.key_name
  user_data = base64encode(templatefile(local.user_data_file, local.user_data_vars))

  security_groups = [module.asg_security_group.security_group_id]

  ebs_optimized     = true
  enable_monitoring = true

  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      ebs = {
        volume_size           = 20
        volume_type           = "gp3"
        delete_on_termination = true
      }
    },
  ]

  tag_specifications = [
    {
      resource_type = "volume"
      tags          = merge(data.aws_default_tags.current.tags, { Name = local.service_name })
    },
  ]

  # IAM role
  create_iam_instance_profile = true

  iam_role_name            = local.ec2_name_prefix
  iam_role_use_name_prefix = false
  iam_role_description     = "Prometheus - EC2 instances - ${local.service_name}"

  iam_role_policies = {
    ssm-agent  = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    prometheus = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
    service    = module.asg_iam_policy.arn
  }

  tags = module.tags.tags
}
