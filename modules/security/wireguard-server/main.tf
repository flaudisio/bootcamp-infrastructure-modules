# ------------------------------------------------------------------------------
# TAGS
# ------------------------------------------------------------------------------

locals {
  tags = {
    environment = var.environment
    service     = var.instance_name
  }
}

# ------------------------------------------------------------------------------
# AMI
# ------------------------------------------------------------------------------

data "aws_ami" "ubuntu" {
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
    values = ["arm64"]
  }
}

# ------------------------------------------------------------------------------
# KEY PAIR
# ------------------------------------------------------------------------------

resource "aws_key_pair" "this" {
  key_name   = var.instance_name
  public_key = var.public_key

  tags = local.tags
}

# ------------------------------------------------------------------------------
# SECURITY GROUP
# ------------------------------------------------------------------------------

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name        = var.instance_name
  description = "WireGuard instance - ${var.instance_name}"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = concat(
    [
      {
        from_port   = var.wireguard_port
        to_port     = var.wireguard_port
        protocol    = "udp"
        description = "WireGuard VPN service"
        cidr_blocks = "0.0.0.0/0"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        description = "WireGuard Portal"
        cidr_blocks = "0.0.0.0/0"
      },
    ],
    [
      for cidr in var.allow_ssh_from_cidrs :
      {
        rule        = "ssh-tcp"
        description = "SSH from allowed CIDR"
        cidr_blocks = cidr
      }
    ]
  )

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      description = "Allow all"
    },
  ]

  tags = local.tags
}

# ------------------------------------------------------------------------------
# SSM PARAMETERS
# ------------------------------------------------------------------------------

resource "random_password" "wg_portal_admin" {
  length      = 32
  special     = false
  min_lower   = 8
  min_upper   = 8
  min_numeric = 8
}

resource "aws_ssm_parameter" "wg_portal_admin_password" {
  name        = format("/%s/wg-portal-admin-password", var.instance_name)
  description = "WireGuard Portal admin password - ${var.instance_name} instance"

  type  = "SecureString"
  value = random_password.wg_portal_admin.result

  tags = local.tags
}

# ------------------------------------------------------------------------------
# IAM POLICY
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "ssm:GetParameter",
    ]
    resources = [
      aws_ssm_parameter.wg_portal_admin_password.arn,
    ]
  }
}

module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.9.2"

  name        = var.instance_name
  description = "Policy for WireGuard instance - ${var.instance_name}"

  policy = data.aws_iam_policy_document.this.json

  tags = local.tags
}

# ------------------------------------------------------------------------------
# EC2 INSTANCE
# ------------------------------------------------------------------------------

locals {
  user_data_file = "${path.module}/templates/user_data.sh.tftpl"

  user_data_vars = {
    environment = var.environment
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.2.1"

  name = var.instance_name

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name                    = aws_key_pair.this.key_name
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(templatefile(local.user_data_file, local.user_data_vars))

  monitoring    = true
  ebs_optimized = true

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 10
    },
  ]

  # IAM role
  create_iam_instance_profile = true

  iam_role_use_name_prefix = false
  iam_role_description     = "Role for WireGuard instance - ${var.instance_name}"

  iam_role_policies = {
    instance = module.iam_policy.arn
  }

  volume_tags = local.tags

  tags = local.tags
}

# ------------------------------------------------------------------------------
# ELASTIC IP
# ------------------------------------------------------------------------------

resource "aws_eip" "this" {
  instance = module.ec2_instance.id
  vpc      = true

  tags = merge(
    local.tags,
    {
      Name = var.instance_name
    }
  )
}

# ------------------------------------------------------------------------------
# ROUTE 53 RECORD
# ------------------------------------------------------------------------------

resource "aws_route53_record" "instance_private" {
  zone_id = var.account_route53_zone_id

  name    = var.instance_name
  type    = "A"
  ttl     = 600
  records = [module.ec2_instance.private_ip]
}

resource "aws_route53_record" "public_endpoint" {
  zone_id = var.account_route53_zone_id

  name    = "vpn"
  type    = "A"
  ttl     = 600
  records = [aws_eip.this.public_ip]
}
