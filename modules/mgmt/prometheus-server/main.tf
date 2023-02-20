# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  service_name = "prometheus-server"
}

# ------------------------------------------------------------------------------
# TAGS
# ------------------------------------------------------------------------------

module "tags" {
  source  = "flaudisio/standard-tags/aws"
  version = "0.1.1"

  environment = var.environment
  service     = local.service_name
  owner       = "monit-team"
}

# ------------------------------------------------------------------------------
# SECURITY GROUP
# ------------------------------------------------------------------------------

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name        = local.service_name
  description = "Prometheus server - ${local.service_name}"
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
  ] : []

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      description = "Allow all"
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

  role_name         = format("%s-ecs-tasks", local.service_name)
  role_description  = "Role for Prometheus server ECS tasks - ${local.service_name}"
  role_requires_mfa = false

  trusted_role_services = [
    "ecs-tasks.amazonaws.com",
  ]

  trusted_role_actions = [
    "sts:AssumeRole",
  ]

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# ECS TASK DEFINITION
# ------------------------------------------------------------------------------

resource "aws_ecs_task_definition" "this" {
  family = local.service_name

  execution_role_arn = module.ecs_task_iam_role.iam_role_arn
  task_role_arn      = module.ecs_task_iam_role.iam_role_arn

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = var.ecs_task_cpu
  memory = var.ecs_task_memory

  container_definitions = jsonencode([
    {
      name      = local.service_name
      image     = var.container_image
      essential = true
      cpu       = var.ecs_task_cpu
      memory    = var.ecs_task_memory
      portMappings = [
        {
          containerPort = 9090
          hostPort      = 9090
          protocol      = "tcp"
        },
      ]
    },
  ])

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# ECS SERVICE
# ------------------------------------------------------------------------------

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
    security_groups  = [module.security_group.security_group_id]
    assign_public_ip = false
  }

  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  tags = module.tags.tags
}
