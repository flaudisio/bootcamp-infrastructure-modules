# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  service_name = "semaphore-server"
  dns_name     = "semaphore"

  lb_name_prefix  = format("%s-lb", local.service_name)
  ec2_name_prefix = format("%s-ec2", local.service_name)
  db_name_prefix  = format("%s-db", local.service_name)

  app_port = 3000
}

# ------------------------------------------------------------------------------
# TAGS
# ------------------------------------------------------------------------------

module "tags" {
  source  = "flaudisio/standard-tags/aws"
  version = "0.2.0"

  environment = var.environment
  service     = local.service_name
  owner       = "infra"
}

# ------------------------------------------------------------------------------
# ACM
# ------------------------------------------------------------------------------

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.3.1"

  domain_name = format("%s.%s", local.dns_name, var.account_route53_zone_name)
  zone_id     = var.account_route53_zone_id

  wait_for_validation = true

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# SECURITY GROUP - LOAD BALANCER
# ------------------------------------------------------------------------------

module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name        = local.lb_name_prefix
  description = "Semaphore - Load balancer - ${local.service_name}"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = [var.vpc_cidr_block]

  ingress_rules = [
    "http-80-tcp",
    "https-443-tcp",
  ]

  egress_rules = ["all-all"]

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# LOAD BALANCER
# ------------------------------------------------------------------------------

module "load_balancer" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.2.1"

  name = local.service_name

  load_balancer_type = "application"

  internal = true

  vpc_id          = var.vpc_id
  subnets         = var.private_subnets
  security_groups = [module.lb_security_group.security_group_id]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      ssl_policy         = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
      target_group_index = 0
    },
  ]

  target_groups = [
    {
      name                 = local.ec2_name_prefix
      backend_protocol     = "HTTP"
      backend_port         = local.app_port
      target_type          = "instance"
      deregistration_delay = 30
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/" # TODO: change health check path
        port                = local.app_port
        healthy_threshold   = 2
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      stickiness = {
        enabled         = true
        type            = "lb_cookie"
        cookie_duration = 3600
      }
    },
  ]

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# AMI
# ------------------------------------------------------------------------------

data "aws_ami" "selected" {
  most_recent = true
  owners      = [var.ec2_ami_owner]

  filter {
    name   = "name"
    values = [var.ec2_ami_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = [var.ec2_ami_architecture]
  }
}

# ------------------------------------------------------------------------------
# KEY PAIR
# ------------------------------------------------------------------------------

resource "aws_key_pair" "this" {
  key_name   = local.service_name
  public_key = var.ec2_public_key

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

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
    ]
    resources = values(aws_ssm_parameter.semaphore_credentials)[*].arn
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/wireguard/*",
    ]
  }

  dynamic "statement" {
    for_each = var.backup_bucket != null ? [true] : []

    content {
      effect = "Allow"
      actions = [
        "s3:ListBucket",
        "s3:GetObject*",
        "s3:PutObject*",
      ]
      resources = [
        "arn:aws:s3:::${var.backup_bucket}",
        "arn:aws:s3:::${var.backup_bucket}/*",
      ]
    }
  }
}

module "asg_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.9.2"

  name        = local.ec2_name_prefix
  description = "Semaphore - EC2 instances - ${local.service_name}"

  policy = data.aws_iam_policy_document.asg_instances.json

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# SECURITY GROUP - ASG/EC2 INSTANCES
# ------------------------------------------------------------------------------

module "asg_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name        = local.ec2_name_prefix
  description = "Semaphore - EC2 instances - ${local.service_name}"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = local.app_port
      to_port                  = local.app_port
      protocol                 = "tcp"
      description              = "App access from load balancer"
      source_security_group_id = module.lb_security_group.security_group_id
    },
  ]

  ingress_with_cidr_blocks = var.allow_vpc_access ? [
    {
      from_port   = local.app_port
      to_port     = local.app_port
      protocol    = "tcp"
      description = "App access from VPC"
      cidr_blocks = var.vpc_cidr_block
    },
    {
      rule        = "ssh-tcp"
      description = "SSH from VPC"
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

  # WARNING: Semaphore does not work well with multiple instances!
  # Use ec2_instance_count > 1 only when required (e.g. for ASG recycling)
  min_size         = var.ec2_instance_count
  max_size         = var.ec2_instance_count
  desired_capacity = var.ec2_instance_count

  ignore_desired_capacity_changes = false

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

  instance_type = var.ec2_instance_type
  image_id      = data.aws_ami.selected.id

  key_name  = aws_key_pair.this.key_name
  user_data = base64encode(templatefile(local.user_data_file, local.user_data_vars))

  security_groups = concat([module.asg_security_group.security_group_id], var.attach_security_groups)

  target_group_arns = module.load_balancer.target_group_arns

  ebs_optimized     = true
  enable_monitoring = true

  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      ebs = {
        volume_size           = 30
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
  iam_role_description     = "Semaphore - EC2 instances - ${local.service_name}"

  iam_role_policies = {
    ssm-agent = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    service   = module.asg_iam_policy.arn
  }

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# SECURITY GROUP - RDS
# ------------------------------------------------------------------------------

module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name        = local.db_name_prefix
  description = "Semaphore - RDS - ${local.service_name}"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      description              = "Access from EC2 instances"
      source_security_group_id = module.asg_security_group.security_group_id
    },
  ]

  ingress_with_cidr_blocks = var.allow_vpc_access ? [
    {
      rule        = "postgresql-tcp"
      description = "Access from VPC"
      cidr_blocks = var.vpc_cidr_block
    },
  ] : []

  egress_rules = ["all-all"]

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# RDS
# ------------------------------------------------------------------------------

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.2.3"

  identifier = local.service_name

  engine         = "postgres"
  engine_version = "14.6"
  instance_class = var.db_instance_type

  db_name  = "semaphore"
  username = "semaphore"
  port     = 5432

  create_random_password = true
  random_password_length = 32

  allocated_storage     = 5
  max_allocated_storage = 20

  vpc_security_group_ids = [module.rds_security_group.security_group_id]
  publicly_accessible    = false

  multi_az = var.db_multi_az

  maintenance_window  = "Sun:04:00-Sun:07:00"
  backup_window       = "01:00-03:00"
  skip_final_snapshot = var.db_skip_final_snapshot

  create_db_subnet_group = false
  db_subnet_group_name   = var.db_subnet_group

  create_db_parameter_group       = true
  parameter_group_use_name_prefix = false

  family = "postgres14"

  create_db_option_group       = true
  option_group_use_name_prefix = false

  major_engine_version = "14"

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# SSM PARAMETERS - SEMAPHORE CREDENTIALS
# ------------------------------------------------------------------------------

resource "random_password" "semaphore_credentials" {
  for_each = toset([
    "admin-password",
    "access-key-encryption",
  ])

  length      = 32
  special     = false
  min_lower   = 8
  min_upper   = 8
  min_numeric = 8
}

resource "aws_ssm_parameter" "semaphore_credentials" {
  for_each = {
    db-name               = module.rds.db_instance_name
    db-user               = module.rds.db_instance_username
    db-pass               = module.rds.db_instance_password
    access-key-encryption = base64encode(random_password.semaphore_credentials["access-key-encryption"].result)
    admin-username        = "admin"
    admin-password        = random_password.semaphore_credentials["admin-password"].result
  }

  name        = format("/%s/%s", local.service_name, each.key)
  description = "Semaphore - App credentials - ${local.service_name}"

  type  = "SecureString"
  value = each.value

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# ROUTE 53 RECORDS
# ------------------------------------------------------------------------------

resource "aws_route53_record" "load_balancer" {
  zone_id = var.account_route53_zone_id

  name = local.dns_name
  type = "A"

  alias {
    name                   = module.load_balancer.lb_dns_name
    zone_id                = module.load_balancer.lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "rds" {
  zone_id = var.account_route53_zone_id

  name    = local.db_name_prefix
  type    = "CNAME"
  ttl     = 300
  records = [module.rds.db_instance_address]
}
