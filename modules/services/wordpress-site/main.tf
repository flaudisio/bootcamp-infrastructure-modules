# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  lb_name_prefix        = format("%s-lb", var.site_name)
  ec2_name_prefix       = format("%s-ec2", var.site_name)
  db_name_prefix        = format("%s-db", var.site_name)
  efs_name_prefix       = format("%s-efs", var.site_name)
  memcached_name_prefix = format("%s-memcached", var.site_name)

  app_port = 8080
}

# ------------------------------------------------------------------------------
# TAGS
# ------------------------------------------------------------------------------

module "tags" {
  source  = "flaudisio/standard-tags/aws"
  version = "0.3.0"

  environment = var.environment
  owner       = var.owner
  service     = var.site_name
}

# ------------------------------------------------------------------------------
# ACM
# ------------------------------------------------------------------------------

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.3.1"

  domain_name = format("%s.%s", var.site_name, var.account_route53_zone_name)
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
  description = "WordPress - Load balancer - ${var.site_name}"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

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

  name = var.site_name

  load_balancer_type = "application"

  vpc_id          = var.vpc_id
  subnets         = var.public_subnets
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
        path                = "/metrics"
        port                = local.app_port
        healthy_threshold   = 2
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
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
  key_name   = var.site_name
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
    resources = values(aws_ssm_parameter.rds_credentials)[*].arn
  }
}

module "asg_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.9.2"

  name        = local.ec2_name_prefix
  description = "WordPress - EC2 instances - ${var.site_name}"

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
  description = "WordPress - EC2 instances - ${var.site_name}"
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
    service     = var.site_name
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.3"

  # Auto scaling group
  name            = var.site_name
  use_name_prefix = false

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  ignore_desired_capacity_changes = true

  vpc_zone_identifier = var.private_subnets

  health_check_grace_period = 300
  health_check_type         = var.asg_health_check_type

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
        volume_size           = 10
        volume_type           = "gp3"
        encrypted             = true
        delete_on_termination = true
      }
    },
  ]

  tag_specifications = [
    {
      resource_type = "volume"
      tags          = merge(data.aws_default_tags.current.tags, { Name = var.site_name })
    },
  ]

  # IAM role
  create_iam_instance_profile = true

  iam_role_name            = local.ec2_name_prefix
  iam_role_use_name_prefix = false
  iam_role_description     = "WordPress - EC2 instances - ${var.site_name}"

  iam_role_policies = {
    ssm-agent = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    service   = module.asg_iam_policy.arn
  }

  # Enable Prometheus scraping on instances
  tags = merge(
    module.tags.tags,
    {
      "prometheus:wordpress-sites" = 1
    }
  )

  # Make sure WordPress containers only spin up after the required infrastructure is created
  depends_on = [
    module.efs,
    module.memcached,
    module.rds,
    aws_ssm_parameter.rds_credentials,
  ]
}

# ------------------------------------------------------------------------------
# SECURITY GROUP - RDS
# ------------------------------------------------------------------------------

module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name        = local.db_name_prefix
  description = "WordPress - RDS - ${var.site_name}"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      description              = "Access from EC2 instances"
      source_security_group_id = module.asg_security_group.security_group_id
    },
  ]

  ingress_with_cidr_blocks = var.allow_vpc_access ? [
    {
      rule        = "mysql-tcp"
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

locals {
  db_name = replace(var.site_name, "-", "")
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.2.3"

  identifier = var.site_name

  engine         = "mariadb"
  engine_version = "10.6"
  instance_class = var.db_instance_type

  db_name  = local.db_name
  username = local.db_name
  port     = 3306

  create_random_password = true
  random_password_length = 32

  storage_type          = "gp3"
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

  family = "mariadb10.6"

  create_db_option_group       = true
  option_group_use_name_prefix = false

  major_engine_version = "10.6"

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# SSM PARAMETERS - RDS CREDENTIALS
# ------------------------------------------------------------------------------

resource "aws_ssm_parameter" "rds_credentials" {
  for_each = {
    db-name = module.rds.db_instance_name
    db-user = module.rds.db_instance_username
    db-pass = module.rds.db_instance_password
  }

  name        = format("/wordpress/%s/%s", var.site_name, each.key)
  description = "WordPress - RDS credentials - ${var.site_name}"

  type  = "SecureString"
  value = each.value

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# SECURITY GROUP - MEMCACHED
# ------------------------------------------------------------------------------

module "memcached_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name        = local.memcached_name_prefix
  description = "WordPress - Memcached - ${var.site_name}"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "memcached-tcp"
      description              = "Access from EC2 instances"
      source_security_group_id = module.asg_security_group.security_group_id
    },
  ]

  ingress_with_cidr_blocks = var.allow_vpc_access ? [
    {
      rule        = "memcached-tcp"
      description = "Access from VPC"
      cidr_blocks = var.vpc_cidr_block
    },
  ] : []

  egress_rules = ["all-all"]

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# ELASTICACHE - MEMCACHED
# ------------------------------------------------------------------------------

module "memcached" {
  source  = "flaudisio/elasticache/aws//modules/memcached"
  version = "0.1.1"

  cluster_id = var.site_name

  engine_version = "1.6.12"
  port           = 11211

  node_type = var.memcached_instance_type

  security_group_ids = [module.memcached_security_group.security_group_id]
  subnet_group_name  = var.memcached_subnet_group

  num_cache_nodes = var.memcached_num_nodes
  az_mode         = var.memcached_multi_az ? "cross-az" : "single-az"

  family = "memcached1.6"

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# SECURITY GROUP - EFS
# ------------------------------------------------------------------------------

module "efs_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name        = local.efs_name_prefix
  description = "WordPress - EFS - ${var.site_name}"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "nfs-tcp"
      description              = "Access from EC2 instances"
      source_security_group_id = module.asg_security_group.security_group_id
    },
  ]

  ingress_with_cidr_blocks = var.allow_vpc_access ? [
    {
      rule        = "nfs-tcp"
      description = "Access from VPC"
      cidr_blocks = var.vpc_cidr_block
    },
  ] : []

  egress_rules = ["all-all"]

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# EFS
# ------------------------------------------------------------------------------

module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "1.1.1"

  name = var.site_name

  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  # Avoid creating the module's default "deny non-secure transport" policy statement
  # (ref: https://github.com/terraform-aws-modules/terraform-aws-efs/blob/v1.1.1/main.tf#L82)
  # Required for the standard NFS client on Ubuntu
  attach_policy = false

  lifecycle_policy = {
    transition_to_ia                    = "AFTER_30_DAYS"
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  create_security_group = false

  mount_targets = {
    for subnet in var.private_subnets :
    subnet => {
      subnet_id       = subnet
      security_groups = [module.efs_security_group.security_group_id]
    }
  }

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# ROUTE 53 RECORDS
# ------------------------------------------------------------------------------

resource "aws_route53_record" "load_balancer" {
  zone_id = var.account_route53_zone_id

  name = var.site_name
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

resource "aws_route53_record" "memcached" {
  zone_id = var.account_route53_zone_id

  name    = local.memcached_name_prefix
  type    = "CNAME"
  ttl     = 300
  records = [module.memcached.cluster_address]
}

resource "aws_route53_record" "efs" {
  zone_id = var.account_route53_zone_id

  name    = local.efs_name_prefix
  type    = "CNAME"
  ttl     = 300
  records = [module.efs.dns_name]
}
