# ------------------------------------------------------------------------------
# SQS QUEUE
# ------------------------------------------------------------------------------

output "sqs_queue_arn" {
  description = "The ARN of the SQS queue"
  value       = module.sqs_queue.queue_arn
}

output "sqs_queue_name" {
  description = "The name of the SQS queue"
  value       = module.sqs_queue.queue_name
}

# ------------------------------------------------------------------------------
# EVENTBRIDGE
# ------------------------------------------------------------------------------

output "eventbridge_rule" {
  description = "The name of the created EventBridge rule"
  value       = values(module.eventbridge.eventbridge_rule_ids)[0]
}

# ------------------------------------------------------------------------------
# LAMBDA FUNCTION
# ------------------------------------------------------------------------------

output "function_arn" {
  description = "The ARN of the Lambda Function"
  value       = module.lambda_function.lambda_function_arn
}

output "function_name" {
  description = "The name of the Lambda Function"
  value       = module.lambda_function.lambda_function_name
}

output "function_invoke_arn" {
  description = "The Invoke ARN of the Lambda Function"
  value       = module.lambda_function.lambda_function_invoke_arn
}

output "function_cloudwatch_log_group" {
  description = "The name of the function's CloudWatch Log Group"
  value       = module.lambda_function.lambda_cloudwatch_log_group_name
}

output "function_iam_role" {
  description = "The name of the IAM role created for the Lambda function"
  value       = module.lambda_function.lambda_role_name
}
