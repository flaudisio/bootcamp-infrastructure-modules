# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  service_name = "semaphore-trigger"

  eventbridge_rule_name = "${local.service_name}-ec2-instances-running"
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
# SQS QUEUE
# ------------------------------------------------------------------------------

module "sqs_queue" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.0.0"

  name = local.service_name

  # Visibility timeout must be greater than the Lambda function timeout
  visibility_timeout_seconds = (var.function_timeout + 2)

  message_retention_seconds = 259200 # 3 days

  create_queue_policy = true

  queue_policy_statements = [
    {
      effect = "Allow"
      principals = [
        {
          type        = "Service"
          identifiers = ["events.amazonaws.com"]
        }
      ]
      actions = [
        "sqs:SendMessage",
      ]
      conditions = [
        {
          test     = "ArnEquals"
          variable = "aws:SourceArn"
          values = [
            format("arn:aws:events:%s:%s:rule/%s", var.aws_region, var.account_id, local.eventbridge_rule_name)
          ]
        }
      ]
    }
  ]

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# EVENTBRIDGE
# ------------------------------------------------------------------------------

module "eventbridge" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "1.17.1"

  create_bus  = false
  create_role = false

  bus_name = "default"

  append_rule_postfix = false

  rules = {
    (local.eventbridge_rule_name) = {
      description = "EC2 instances state change to 'running'"
      event_pattern = jsonencode(
        # Ref: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-instance-state-changes.html
        {
          source      = ["aws.ec2"]
          detail-type = ["EC2 Instance State-change Notification"]
          detail = {
            state = ["running"]
          }
        }
      )
      enabled = var.enable_eventbridge_rules
    }
  }

  targets = {
    (local.eventbridge_rule_name) = [
      {
        name = "ec2-running-events-to-sqs"
        arn  = module.sqs_queue.queue_arn
      }
    ]
  }

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# SECURITY GROUP
# ------------------------------------------------------------------------------

module "lambda_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.16.2"

  name        = local.service_name
  description = "Semaphore Trigger function - ${local.service_name}"
  vpc_id      = var.vpc_id

  egress_rules = ["all-all"]

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# LAMBDA FUNCTION
# ------------------------------------------------------------------------------

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "4.7.1"

  function_name = local.service_name
  description   = "Function for triggering Ansible Semaphore tasks"

  handler       = "semaphore_trigger/app.handler"
  runtime       = "python3.9"
  architectures = ["x86_64"]

  memory_size = var.function_memory_size
  timeout     = var.function_timeout

  # VPC config
  vpc_subnet_ids         = var.private_subnets
  vpc_security_group_ids = [module.lambda_security_group.security_group_id]
  attach_network_policy  = true

  # This module creates only the function infrastructure, so we use a "dummy" package.
  # The function code is deployed from https://code.ifoodcorp.com.br/ifood/sre/cloud-infra/tap/management-functions
  # Ref: https://github.com/terraform-aws-modules/terraform-aws-lambda/tree/v4.7.1#lambda-function-or-lambda-layer-with-the-deployable-artifact-maintained-separately-from-the-infrastructure
  create_package          = false
  ignore_source_code_hash = true

  # IMPORTANT: if you modify this path the function code MUST be redeployed from its repository
  local_existing_package = "${path.module}/src/dummy.zip"

  # Publishing is disabled to avoid permission-related diffs after updating the function code
  publish = false

  # App configuration
  environment_variables = {
    ST_ENABLE_WORKFLOW      = var.enable_lambda_function
    ST_ENVIRONMENT          = var.environment
    ST_SEMAPHORE_URL        = var.semaphore_endpoint
    ST_SEMAPHORE_TOKEN      = var.semaphore_token
    ST_SEMAPHORE_PROJECT_ID = var.semaphore_project_id
    ST_SERVICE_TAG_NAME     = "service"
    ST_TARGET_REGION        = var.aws_region
  }

  # CloudWatch Logs
  cloudwatch_logs_retention_in_days = 7

  # Trigger and permissions
  create_current_version_allowed_triggers   = false
  create_unqualified_alias_allowed_triggers = true

  event_source_mapping = {
    sqs-queue = {
      event_source_arn = module.sqs_queue.queue_arn
    }
  }

  allowed_triggers = {
    sqs-queue = {
      principal  = "sqs.amazonaws.com"
      source_arn = module.sqs_queue.queue_arn
    }
  }

  # IAM role and policy
  role_name        = format("%s-function", local.service_name)
  role_description = "Role for ${local.service_name} Lambda function"

  attach_policy_statements = true

  policy_statements = {
    SqsPermissions = {
      effect = "Allow"
      actions = [
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ReceiveMessage",
      ]
      resources = [
        module.sqs_queue.queue_arn,
      ]
    }
    Ec2Permissions = {
      effect = "Allow"
      actions = [
        "ec2:DescribeInstances",
      ]
      resources = ["*"]
    }
  }

  tags = module.tags.tags
}
