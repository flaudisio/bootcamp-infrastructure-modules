# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  service_name = "semaphore-server"
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
# SECURITY GROUP
# ------------------------------------------------------------------------------

module "ec2_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name        = local.service_name
  description = "Semaphore instance - ${local.service_name}"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = concat(
    [
      {
        rule        = "http-80-tcp"
        cidr_blocks = var.vpc_cidr_block
      },
      {
        rule        = "https-443-tcp"
        cidr_blocks = var.vpc_cidr_block
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

  egress_rules = ["all-all"]

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# SSM PARAMETERS - SEMAPHORE CREDENTIALS
# ------------------------------------------------------------------------------

resource "random_password" "semaphore_credentials" {
  for_each = toset([
    "admin-password",
    "db-pass",
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
    db-name               = "semaphore"
    db-user               = "semaphore"
    db-pass               = random_password.semaphore_credentials["db-pass"].result
    access-key-encryption = base64encode(random_password.semaphore_credentials["access-key-encryption"].result)
    admin-username        = "admin"
    admin-password        = random_password.semaphore_credentials["admin-password"].result
  }

  name        = format("/%s/%s", local.service_name, each.key)
  description = "Semaphore credentials"

  type  = "SecureString"
  value = each.value

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# IAM POLICY - EC2
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "this" {
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
}

module "ec2_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.9.2"

  name        = format("%s-ec2", local.service_name)
  description = "Policy for Semaphore instance - ${local.service_name}"

  policy = data.aws_iam_policy_document.this.json

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# EC2 INSTANCE
# ------------------------------------------------------------------------------

locals {
  user_data_file = "${path.module}/templates/user_data.sh.tftpl"

  user_data_vars = {
    environment = var.environment
    service     = local.service_name
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.2.1"

  name = local.service_name

  ami           = data.aws_ami.selected.id
  instance_type = var.instance_type

  key_name                    = aws_key_pair.this.key_name
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [module.ec2_security_group.security_group_id]
  associate_public_ip_address = false

  user_data_base64 = base64encode(templatefile(local.user_data_file, local.user_data_vars))

  monitoring    = true
  ebs_optimized = true

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 20
    },
  ]

  # IAM role
  create_iam_instance_profile = true

  iam_role_name            = format("%s-ec2", local.service_name)
  iam_role_use_name_prefix = false
  iam_role_description     = "Role for Semaphore instance - ${local.service_name}"

  iam_role_policies = {
    ssm-agent = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    service   = module.ec2_iam_policy.arn
  }

  volume_tags = module.tags.tags

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# ROUTE 53 RECORDS
# ------------------------------------------------------------------------------

resource "aws_route53_record" "endpoint" {
  zone_id = var.account_route53_zone_id

  name    = "semaphore"
  type    = "A"
  ttl     = 600
  records = [module.ec2_instance.private_ip]
}
