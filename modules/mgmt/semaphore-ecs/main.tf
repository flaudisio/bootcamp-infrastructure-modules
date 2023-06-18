# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  service_name  = "semaphore"
  dns_subdomain = coalesce(var.subdomain, local.service_name)

  lb_name_prefix       = format("%s-lb", local.service_name)
  ecs_task_name_prefix = format("%s-ecs-tasks", local.service_name)
  db_name_prefix       = format("%s-db", local.service_name)

  semaphore_port = 3000

  # App details
  semaphore_endpoint = format("https://%s", aws_route53_record.load_balancer.fqdn)
}

# ------------------------------------------------------------------------------
# TAGS
# ------------------------------------------------------------------------------

module "tags" {
  source  = "flaudisio/standard-tags/aws"
  version = "0.3.0"

  environment = var.environment
  owner       = "infra"
  service     = local.service_name
}

# ------------------------------------------------------------------------------
# ACM
# ------------------------------------------------------------------------------

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.3.1"

  domain_name = format("%s.%s", local.dns_subdomain, var.account_route53_zone_name)
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
  description = "${local.service_name} - Load balancer"
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
      name                 = local.ecs_task_name_prefix
      backend_protocol     = "HTTP"
      backend_port         = local.semaphore_port
      target_type          = "ip"
      deregistration_delay = 30
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/api/ping"
        port                = local.semaphore_port
        healthy_threshold   = 2
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      stickiness = {
        # Enable stickiness to alleviate session problems in the (eventual) moments
        # when more than one instance is deployed
        enabled         = true
        type            = "lb_cookie"
        cookie_duration = 3600
      }
    },
  ]

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# ECS CLUSTER
# ------------------------------------------------------------------------------

module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "4.1.3"

  cluster_name = local.service_name

  cluster_settings = {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# IAM POLICY - ECS TASKS
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "ecs_tasks" {
  # Required by Ansible dynamic inventory
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
    ]
    resources = ["*"]
  }

  # Required to configure services via Ansible's 'amazon.aws.aws_ssm' lookup
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/*",
    ]
  }

  # Required by ECS 'execute-command'
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = ["*"]
  }

  # Backup bucket
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

module "ecs_task_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.9.2"

  name        = local.ecs_task_name_prefix
  description = "${local.service_name} - ECS tasks"

  policy = data.aws_iam_policy_document.ecs_tasks.json

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# IAM ROLE - ECS TASKS
# ------------------------------------------------------------------------------

module "ecs_task_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.11.2"

  create_role             = true
  create_instance_profile = false

  role_name         = local.ecs_task_name_prefix
  role_description  = "${local.service_name} - ECS tasks"
  role_requires_mfa = false

  trusted_role_services = [
    "ecs-tasks.amazonaws.com",
  ]

  trusted_role_actions = [
    "sts:AssumeRole",
  ]

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    module.ecs_task_iam_policy.arn,
  ]

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# SECURITY GROUP - ECS TASKS
# ------------------------------------------------------------------------------

module "ecs_task_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name        = local.ecs_task_name_prefix
  description = "${local.service_name} - ECS tasks"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = local.semaphore_port
      to_port                  = local.semaphore_port
      protocol                 = "tcp"
      description              = "App access from load balancer"
      source_security_group_id = module.lb_security_group.security_group_id
    },
  ]

  ingress_with_cidr_blocks = var.allow_vpc_access ? [
    {
      from_port   = local.semaphore_port
      to_port     = local.semaphore_port
      protocol    = "tcp"
      description = "App access from VPC"
      cidr_blocks = var.vpc_cidr_block
    },
  ] : []

  egress_rules = ["all-all"]

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP - ECS TASKS
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "this" {
  name = format("/aws/ecs/%s", local.service_name)

  retention_in_days = var.logs_retention_in_days

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# ECS TASK DEFINITION
# ------------------------------------------------------------------------------

locals {
  semaphore_admin_email = coalesce(
    var.semaphore_admin_email,
    format("%s@%s", var.semaphore_admin_username, var.account_route53_zone_name)
  )

  semaphore_tmp_path = "/semaphore/tmp"

  # Note: integer values are converted to string as required by the 'container_definitions' argument
  semaphore_env_vars = {
    SEMAPHORE_DB_DIALECT         = "postgres"
    SEMAPHORE_DB_HOST            = module.rds.db_instance_address
    SEMAPHORE_DB_PORT            = tostring(module.rds.db_instance_port)
    SEMAPHORE_DB                 = module.rds.db_instance_name
    SEMAPHORE_DB_USER            = module.rds.db_instance_username
    SEMAPHORE_ADMIN              = var.semaphore_admin_username
    SEMAPHORE_ADMIN_NAME         = var.semaphore_admin_fullname
    SEMAPHORE_ADMIN_EMAIL        = local.semaphore_admin_email
    SEMAPHORE_WEB_ROOT           = local.semaphore_endpoint
    SEMAPHORE_MAX_PARALLEL_TASKS = tostring(var.semaphore_max_parallel_tasks)
    SEMAPHORE_TMP_PATH           = local.semaphore_tmp_path
  }

  housekeeper_env_vars = {
    SCHEDULE           = var.housekeeper_schedule
    SEMAPHORE_TMP_PATH = local.semaphore_tmp_path
  }

  container_log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-region        = var.aws_region
      awslogs-group         = aws_cloudwatch_log_group.this.name
      awslogs-stream-prefix = "ecs"
    }
  }
}

resource "aws_ecs_task_definition" "this" {
  family = local.service_name

  execution_role_arn = module.ecs_task_iam_role.iam_role_arn
  task_role_arn      = module.ecs_task_iam_role.iam_role_arn

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = upper(var.ecs_task_architecture)
  }

  cpu    = var.ecs_task_cpu
  memory = var.ecs_task_memory

  ephemeral_storage {
    size_in_gib = var.semaphore_storage_size
  }

  # Ref: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definitions
  container_definitions = jsonencode([
    {
      name      = "semaphore"
      image     = var.semaphore_image
      essential = true
      portMappings = [
        {
          containerPort = local.semaphore_port
          protocol      = "tcp"
        },
      ]
      environment = [
        for k, v in merge(local.semaphore_env_vars, var.semaphore_custom_env_vars) :
        {
          name  = k
          value = v
        }
      ]
      secrets = [
        for k, v in aws_ssm_parameter.semaphore_credentials :
        {
          name      = k
          valueFrom = v.name
        }
      ]
      logConfiguration = local.container_log_configuration
    },
    {
      name      = "housekeeper"
      image     = var.housekeeper_image
      essential = false
      environment = [
        for k, v in local.housekeeper_env_vars :
        {
          name  = k
          value = v
        }
      ]
      volumesFrom = [
        {
          sourceContainer = "semaphore"
          readOnly        = false
        }
      ]
      logConfiguration = local.container_log_configuration
    },
  ])

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# ECS SERVICE
# ------------------------------------------------------------------------------

locals {
  # Decode the applied container definition to HCL to make it easier to reference its attributes below
  semaphore_container_definition = jsondecode(aws_ecs_task_definition.this.container_definitions)[0]
}

resource "aws_ecs_service" "this" {
  cluster = module.ecs_cluster.cluster_id

  name = local.service_name

  task_definition        = format("%s:%s", aws_ecs_task_definition.this.family, aws_ecs_task_definition.this.revision)
  desired_count          = var.container_count
  launch_type            = "FARGATE"
  platform_version       = "LATEST"
  enable_execute_command = true

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  force_new_deployment               = false

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = concat([module.ecs_task_security_group.security_group_id], var.attach_security_groups)
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.load_balancer.target_group_arns[0]
    container_name   = local.semaphore_container_definition.name
    container_port   = local.semaphore_container_definition.portMappings[0].containerPort
  }

  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# SECURITY GROUP - RDS
# ------------------------------------------------------------------------------

module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name        = local.db_name_prefix
  description = "${local.service_name} - RDS"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      description              = "Access from ECS tasks"
      source_security_group_id = module.ecs_task_security_group.security_group_id
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
  version = "5.9.0"

  identifier = local.service_name

  engine         = "postgres"
  engine_version = "14.6"
  instance_class = var.db_instance_type

  db_name  = "semaphore"
  username = "semaphore"
  port     = 5432

  create_random_password = true
  random_password_length = 32

  storage_type          = "gp3"
  allocated_storage     = 5
  max_allocated_storage = 20

  vpc_security_group_ids = [module.rds_security_group.security_group_id]
  publicly_accessible    = false

  multi_az = var.db_multi_az

  maintenance_window = "Sun:04:00-Sun:07:00"
  backup_window      = "01:00-03:00"

  snapshot_identifier   = var.db_snapshot_identifier
  skip_final_snapshot   = var.db_skip_final_snapshot
  copy_tags_to_snapshot = true

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
    "cookie-hash",
    "cookie-encryption",
    "access-key-encryption",
    "admin-password",
  ])

  length      = 32
  special     = false
  min_lower   = 8
  min_upper   = 8
  min_numeric = 8
}

resource "aws_ssm_parameter" "semaphore_credentials" {
  # Note: map keys MUST be valid Semaphore environment variables; see 'container_definitions' for details
  for_each = {
    SEMAPHORE_DB_PASS               = module.rds.db_instance_password
    SEMAPHORE_COOKIE_HASH           = base64encode(random_password.semaphore_credentials["cookie-hash"].result)
    SEMAPHORE_COOKIE_ENCRYPTION     = base64encode(random_password.semaphore_credentials["cookie-encryption"].result)
    SEMAPHORE_ACCESS_KEY_ENCRYPTION = base64encode(random_password.semaphore_credentials["access-key-encryption"].result)
    SEMAPHORE_ADMIN_PASSWORD        = random_password.semaphore_credentials["admin-password"].result
  }

  name        = format("/%s/%s", local.service_name, each.key)
  description = "${local.service_name} - App credentials"

  type  = "SecureString"
  value = each.value

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# ROUTE 53 RECORDS
# ------------------------------------------------------------------------------

resource "aws_route53_record" "load_balancer" {
  zone_id = var.account_route53_zone_id

  name = local.dns_subdomain
  type = "A"

  alias {
    name                   = module.load_balancer.lb_dns_name
    zone_id                = module.load_balancer.lb_zone_id
    evaluate_target_health = true
  }
}
