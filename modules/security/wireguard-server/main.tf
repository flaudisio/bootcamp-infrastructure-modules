# ------------------------------------------------------------------------------
# TAGS
# ------------------------------------------------------------------------------

locals {
  service_name = "wireguard"

  tags = {
    environment = var.environment
    service     = local.service_name
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
  key_name   = local.service_name
  public_key = var.public_key

  tags = local.tags
}

# ------------------------------------------------------------------------------
# SECURITY GROUP
# ------------------------------------------------------------------------------

module "ec2_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name        = local.service_name
  description = "WireGuard instance - ${local.service_name}"
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
        rule        = "https-443-tcp"
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
# IAM POLICY - EC2
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "ssm:GetParameter",
    ]
    resources = values(aws_ssm_parameter.wg_portal_credentials)[*].arn
  }
}

module "ec2_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.9.2"

  name        = format("%s-ec2", local.service_name)
  description = "Policy for WireGuard instance - ${local.service_name}"

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

  name = local.service_name

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name                    = aws_key_pair.this.key_name
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [module.ec2_security_group.security_group_id]
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
  iam_role_description     = "Role for WireGuard instance - ${local.service_name}"

  iam_role_policies = {
    ssm-agent = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    service   = module.ec2_iam_policy.arn,
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
      Name = local.service_name
    }
  )
}

# ------------------------------------------------------------------------------
# IAM USER - SMTP
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "smtp" {
  statement {
    effect    = "Allow"
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}

module "smtp_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.9.2"

  name        = format("%s-smtp", local.service_name)
  description = "Policy for WireGuard SMTP user - ${local.service_name}"

  policy = data.aws_iam_policy_document.smtp.json

  tags = local.tags
}

module "smtp_iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.10.0"

  name = format("%s-smtp", local.service_name)

  force_destroy = true

  create_iam_access_key         = true
  create_iam_user_login_profile = false

  tags = local.tags
}

resource "aws_iam_user_policy_attachment" "smtp_user" {
  user       = module.smtp_iam_user.iam_user_name
  policy_arn = module.smtp_iam_policy.arn
}

# ------------------------------------------------------------------------------
# SSM PARAMETERS - WG PORTAL
# ------------------------------------------------------------------------------

resource "random_password" "wg_portal_admin" {
  length      = 32
  special     = false
  min_lower   = 8
  min_upper   = 8
  min_numeric = 8
}

resource "aws_ssm_parameter" "wg_portal_credentials" {
  for_each = {
    wg-portal-admin-username = format("wg-admin@%s", var.account_route53_zone_name)
    wg-portal-admin-password = random_password.wg_portal_admin.result
    wg-portal-email-username = module.smtp_iam_user.iam_access_key_id
    wg-portal-email-password = module.smtp_iam_user.iam_access_key_ses_smtp_password_v4
  }

  name        = format("/%s/%s", local.service_name, each.key)
  description = "WireGuard Portal credentials"

  type  = "SecureString"
  value = each.value

  tags = local.tags
}

# ------------------------------------------------------------------------------
# ROUTE 53 RECORDS
# ------------------------------------------------------------------------------

resource "aws_route53_record" "instance_private" {
  zone_id = var.account_route53_zone_id

  name    = local.service_name
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
