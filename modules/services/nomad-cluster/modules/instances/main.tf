# ------------------------------------------------------------------------------
# TAGS
# ------------------------------------------------------------------------------

module "tags" {
  source  = "flaudisio/standard-tags/aws"
  version = "0.3.0"

  environment = var.environment
  owner       = var.owner
  service     = var.service_name
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
# IAM POLICY
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "asg_instances" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
    ]
    resources = ["*"]
  }
}

module "asg_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.9.2"

  name        = var.service_name
  description = "${var.service_name} - EC2 instances"

  policy = data.aws_iam_policy_document.asg_instances.json

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
    service     = var.service_name
    role        = var.service_role
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.7.1"

  # Auto scaling group
  name            = var.service_name
  use_name_prefix = false

  min_size         = var.instance_count
  max_size         = var.instance_count
  desired_capacity = var.instance_count

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

  key_name  = var.key_name
  user_data = base64encode(templatefile(local.user_data_file, local.user_data_vars))

  security_groups = var.security_groups

  ebs_optimized     = true
  enable_monitoring = true

  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      ebs = {
        volume_size           = var.root_volume_size
        volume_type           = "gp3"
        encrypted             = true
        delete_on_termination = true
      }
    },
  ]

  tag_specifications = [
    {
      resource_type = "volume"
      tags          = merge(data.aws_default_tags.current.tags, { Name = var.service_name })
    },
  ]

  # IAM role
  create_iam_instance_profile = true

  iam_role_name            = var.service_name
  iam_role_use_name_prefix = false
  iam_role_description     = "${var.service_name} - EC2 instances"

  iam_role_policies = {
    ssm-agent = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    service   = module.asg_iam_policy.arn
  }

  tags = module.tags.tags
}
