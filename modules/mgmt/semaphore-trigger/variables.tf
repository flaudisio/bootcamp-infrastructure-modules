# ------------------------------------------------------------------------------
# COMMON VARIABLES
# ------------------------------------------------------------------------------

variable "account_id" {
  description = "The ID of the account"
  type        = string
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

# ------------------------------------------------------------------------------
# MODULE VARIABLES
# ------------------------------------------------------------------------------

variable "vpc_id" {
  description = "The ID of the VPC where the Lambda function will be deployed on"
  type        = string
}

variable "private_subnets" {
  description = "A list of private subnet IDs to deploy the Lambda function to"
  type        = list(string)
}

variable "enable_eventbridge_rules" {
  description = "Whether to make the EventBridge rules to watch events. Change to `false` to disable the entire Semaphore Trigger workflow"
  type        = bool
  default     = true
}

variable "enable_lambda_function" {
  description = "Whether to enable the Lambda function. Change to `false` to ignore new instance launches"
  type        = bool
  default     = true
}

variable "function_memory_size" {
  description = "The amount of memory (in MB) available to the function at runtime"
  type        = number
  default     = 128
}

variable "function_timeout" {
  description = "The amount of time (in seconds) the function has to run"
  type        = number
  default     = 60
}

variable "semaphore_endpoint" {
  description = "The endpoint of the Ansible Semaphore server"
  type        = string
}

variable "semaphore_token" {
  description = "The token of the Ansible Semaphore server"
  type        = string
}

variable "semaphore_project_id" {
  description = "The ID of the Ansible Semaphore project that manages instances"
  type        = number
}
