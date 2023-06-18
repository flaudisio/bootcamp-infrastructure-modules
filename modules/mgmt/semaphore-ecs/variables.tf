# ------------------------------------------------------------------------------
# COMMON VARIABLES
# ------------------------------------------------------------------------------

variable "account_route53_zone_name" {
  description = "The name of the account's Route 53 zone"
  type        = string
}

variable "account_route53_zone_id" {
  description = "The ID of the account's Route 53 zone"
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
  description = "The ID of the VPC where the resources will be deployed on"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC where the resources will be deployed on"
  type        = string
}

variable "private_subnets" {
  description = "A list of private subnet IDs to deploy the instances to"
  type        = list(string)
}

variable "attach_security_groups" {
  description = "A list of security groups to be attached to the instance"
  type        = list(string)
  default     = []
}

variable "allow_vpc_access" {
  description = "Whether to allow VPC-originating access to private resources. Only enable for debugging purposes!"
  type        = bool
  default     = false
}

variable "subdomain" {
  description = "The name of the subdomain to be created in the account's Route 53 zone; defaults to the service name"
  type        = string
  default     = null
}

variable "container_count" {
  description = "The number of Semaphore containers to run"
  type        = number
  default     = 1
}

variable "ecs_task_architecture" {
  description = "The CPU architecture to run the containers"
  type        = string
  default     = "arm64"

  validation {
    condition     = contains(["x86_64", "arm64"], var.ecs_task_architecture)
    error_message = "The container architecture must be one of 'x86_64', 'arm64' (case sensitive)."
  }
}

variable "ecs_task_cpu" {
  description = "The amount of CPU shares available to containers"
  type        = number
  default     = 512
}

variable "ecs_task_memory" {
  description = "The amount of memory available to containers"
  type        = number
  default     = 1024
}

variable "db_instance_type" {
  description = "The type of the DB instance"
  type        = string
}

variable "db_subnet_group" {
  description = "The name of the DB subnet group"
  type        = string
}

variable "db_multi_az" {
  description = "Whether to enable multi-AZ deployment of the database"
  type        = bool
  default     = true
}

variable "db_snapshot_identifier" {
  description = "The identifier of an existing snapshot to create the database from"
  type        = string
  default     = null
}

variable "db_skip_final_snapshot" {
  description = "Whether to enable multi-AZ deployment of the database"
  type        = bool
  default     = false
}

variable "backup_bucket" {
  description = "The name of an S3 bucket to be used to initialize the Semaphore database from a backup file"
  type        = string
  default     = null
}

variable "logs_retention_in_days" {
  description = "The number of days to retain container logs on CloudWatch Logs"
  type        = number
  default     = 7
}

variable "semaphore_image" {
  description = "Docker image to run the Semaphore containers"
  type        = string
  default     = "flaudisio/bootcamp-semaphore:2.8.89-debian"
}

variable "semaphore_storage_size" {
  description = "The size of the ephemeral storage available to the Semaphore container"
  type        = number
  default     = 30
}

variable "semaphore_custom_env_vars" {
  description = "A map of custom environment variables to be configured in the Semaphore container"
  type        = map(string)
  default     = {}
}

variable "semaphore_admin_username" {
  description = "The username of the admin user"
  type        = string
  default     = "admin"
}

variable "semaphore_admin_fullname" {
  description = "The full name of the admin user"
  type        = string
  default     = "Semaphore Admin"
}

variable "semaphore_admin_email" {
  description = "The email of the admin user. Defaults to `<admin-username>@<account-domain>`"
  type        = string
  default     = null
}

variable "semaphore_max_parallel_tasks" {
  description = "Max allowed parallel tasks if `semaphore_concurrency_mode != \"\"`. Can also be set/changed within the web UI (project settings)"
  type        = number
  default     = 2
}

variable "housekeeper_image" {
  description = "The semaphore-housekeeper image"
  type        = string
  default     = "flaudisio/bootcamp-semaphore-housekeeper:0.1.0"
}

variable "housekeeper_schedule" {
  description = "The semaphore-housekeeper schedule"
  type        = string
  default     = "0 * * * *"
}
