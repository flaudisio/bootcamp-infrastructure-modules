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

variable "owner" {
  description = "The team that owns the created resources"
  type        = string
}

variable "service" {
  description = "The service related to the created resources"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "append_environment" {
  description = "Whether to append the environment name to the bucket name"
  type        = bool
  default     = false
}

variable "append_account_id" {
  description = "Whether to append the account ID to the bucket name"
  type        = bool
  default     = false
}

variable "append_region" {
  description = "Whether to append the current AWS region to the bucket name"
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "The object ownership configuration"
  type        = string
  default     = "BucketOwnerEnforced"
}
