# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  cluster_domain = format("%s.%s", var.cluster_name, var.account_route53_zone_name)

  ec2_name_prefix = format("%s-ec2", var.cluster_name)

  # Base path on SSM Parameter Store
  ssm_base_path = format("/consul/%s", var.cluster_name)

  # Common health check configuration for all target groups
  target_group_health_check = {
    enabled             = true
    interval            = 10
    path                = "/v1/health/service/consul"
    port                = 8500 # Consul HTTP API
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200-399"
  }
}

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
# ACM
# ------------------------------------------------------------------------------

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.3.1"

  domain_name = local.cluster_domain
  zone_id     = var.account_route53_zone_id

  wait_for_validation = true

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# LOAD BALANCER
# ------------------------------------------------------------------------------

module "load_balancer" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.6.0"

  name = var.cluster_name

  load_balancer_type = "network"

  internal = true

  vpc_id  = var.vpc_id
  subnets = var.private_subnets

  https_listeners = [
    {
      port               = 443
      protocol           = "TLS"
      certificate_arn    = module.acm.acm_certificate_arn
      ssl_policy         = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
      target_group_index = 0 # HTTP API
    },
  ]

  http_tcp_listeners = [
    {
      port               = 8300
      protocol           = "TCP"
      target_group_index = 1
    },
    {
      port               = 8301
      protocol           = "TCP_UDP"
      target_group_index = 2
    },
    {
      port               = 8302
      protocol           = "TCP_UDP"
      target_group_index = 3
    },
    {
      port               = 8600
      protocol           = "TCP_UDP"
      target_group_index = 4
    },
  ]

  target_groups = [
    {
      name                 = format("%s-http-api", var.cluster_name)
      backend_protocol     = "TCP"
      backend_port         = 8500
      target_type          = "instance"
      deregistration_delay = 10
      health_check         = local.target_group_health_check
      tags                 = module.tags.tags
    },
    {
      name                 = format("%s-server-rpc", var.cluster_name)
      backend_protocol     = "TCP"
      backend_port         = 8300
      target_type          = "instance"
      deregistration_delay = 10
      health_check         = local.target_group_health_check
      tags                 = module.tags.tags
    },
    {
      name                 = format("%s-serf-lan", var.cluster_name)
      backend_protocol     = "TCP_UDP"
      backend_port         = 8301
      target_type          = "instance"
      deregistration_delay = 10
      health_check         = local.target_group_health_check
      tags                 = module.tags.tags
    },
    {
      name                 = format("%s-serf-wan", var.cluster_name)
      backend_protocol     = "TCP_UDP"
      backend_port         = 8302
      target_type          = "instance"
      deregistration_delay = 10
      health_check         = local.target_group_health_check
      tags                 = module.tags.tags
    },
    {
      name                 = format("%s-dns-server", var.cluster_name)
      backend_protocol     = "TCP_UDP"
      backend_port         = 8600
      target_type          = "instance"
      deregistration_delay = 10
      health_check         = local.target_group_health_check
      tags                 = module.tags.tags
    },
  ]

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
  key_name   = var.cluster_name
  public_key = var.cluster_public_key

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# IAM POLICY - ASG/EC2 INSTANCES
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "asg_instances" {
  # Required by Ansible dynamic inventory
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
    ]
    resources = ["*"]
  }

  # Required by Ansible 'amazon.aws.aws_ssm' lookup
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
    ]
    resources = values(aws_ssm_parameter.cluster_secrets)[*].arn
  }
}

module "asg_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.9.2"

  name        = local.ec2_name_prefix
  description = "${var.cluster_name} - EC2 instances"

  policy = data.aws_iam_policy_document.asg_instances.json

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# SECURITY GROUP - EC2 INSTANCES
# ------------------------------------------------------------------------------

module "asg_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = local.ec2_name_prefix
  description = "${var.cluster_name} - EC2 instances"
  vpc_id      = var.vpc_id

  ingress_with_self = [
    # Allow communication between cluster member instances
    {
      rule        = "all-all"
      description = "Self"
    },
  ]

  ingress_with_cidr_blocks = concat(
    # Allow API access from load balancer and RPC/Gossip access from Consul clients in the VPC
    [
      {
        from_port   = 8500
        to_port     = 8500
        protocol    = "tcp"
        description = "http-api"
        cidr_blocks = var.vpc_cidr_block
      },
      {
        from_port   = 8300
        to_port     = 8300
        protocol    = "tcp"
        description = "server-rpc"
        cidr_blocks = var.vpc_cidr_block
      },
      {
        from_port   = 8301
        to_port     = 8301
        protocol    = "tcp"
        description = "serf-lan"
        cidr_blocks = var.vpc_cidr_block
      },
      {
        from_port   = 8301
        to_port     = 8301
        protocol    = "udp"
        description = "serf-lan"
        cidr_blocks = var.vpc_cidr_block
      },
    ],
    # Allow administrative access when enabled
    var.allow_vpc_access ? [
      {
        rule        = "ssh-tcp"
        description = "Access from VPC"
        cidr_blocks = var.vpc_cidr_block
      },
    ] : []
  )

  egress_rules = ["all-all"]

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# EC2 INSTANCES
# ------------------------------------------------------------------------------

data "aws_default_tags" "current" {}

locals {
  user_data_file = "${path.module}/templates/user_data.sh.tftpl"

  user_data_vars = {
    environment = var.environment
    service     = var.cluster_name
    role        = "consul-node"
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.7.1"

  # Auto scaling group
  name            = var.cluster_name
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
        volume_size           = var.instance_volume_size
        volume_type           = "gp3"
        encrypted             = true
        delete_on_termination = true
      }
    },
  ]

  tag_specifications = [
    {
      resource_type = "volume"
      tags          = merge(data.aws_default_tags.current.tags, { Name = var.cluster_name })
    },
  ]

  # IAM role
  create_iam_instance_profile = true

  iam_role_name            = local.ec2_name_prefix
  iam_role_use_name_prefix = false
  iam_role_description     = "${var.cluster_name} - EC2 instances"

  iam_role_policies = {
    ssm-agent = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    service   = module.asg_iam_policy.arn
  }

  # Specific tags for the EC2 instances
  autoscaling_group_tags = {
    "ansible:ssm-cluster-path" = local.ssm_base_path
  }

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# CLUSTER CA CERTIFICATE
# ------------------------------------------------------------------------------

resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem       = tls_private_key.ca.private_key_pem
  validity_period_hours = 87660
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "digital_signature",
    "key_encipherment",
  ]

  subject {
    common_name  = local.cluster_domain
    organization = var.account_name
  }
}

# ------------------------------------------------------------------------------
# CLUSTER GOSSIP ENCRYPTION KEY
# ------------------------------------------------------------------------------

resource "random_password" "gossip_key" {
  length      = 32
  special     = false
  min_lower   = 8
  min_upper   = 8
  min_numeric = 8
}

# ------------------------------------------------------------------------------
# SSM PARAMETERS
# ------------------------------------------------------------------------------

resource "aws_ssm_parameter" "cluster_secrets" {
  for_each = {
    ca-key     = tls_private_key.ca.private_key_pem
    ca-cert    = tls_self_signed_cert.ca.cert_pem
    gossip-key = base64encode(random_password.gossip_key.result)
  }

  name        = format("%s/%s", local.ssm_base_path, each.key)
  description = "${var.cluster_name} - Cluster secrets"

  type  = "SecureString"
  value = each.value

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# ROUTE 53 RECORDS
# ------------------------------------------------------------------------------

resource "aws_route53_record" "load_balancer" {
  zone_id = var.account_route53_zone_id

  name = local.cluster_domain
  type = "A"

  alias {
    name                   = module.load_balancer.lb_dns_name
    zone_id                = module.load_balancer.lb_zone_id
    evaluate_target_health = true
  }
}
