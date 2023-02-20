# ------------------------------------------------------------------------------
# COMMON VARIABLES
# ------------------------------------------------------------------------------

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
  description = "A list of private subnet IDs to deploy the containers to"
  type        = list(string)
}

variable "allow_vpc_access" {
  description = "Whether to allow any VPC-originating access to private resources. Only enable for debugging purposes!"
  type        = bool
  default     = false
}

variable "container_image" {
  description = "Docker image to run the Prometheus containers"
  type        = string
  default     = "prom/prometheus:2.37.6"
}

variable "container_count" {
  description = "The number of Prometheus containers to run"
  type        = number
  default     = 1
}

variable "ecs_task_cpu" {
  description = "The ECS task CPU"
  type        = number
  default     = 256
}

variable "ecs_task_memory" {
  description = "The ECS task memory"
  type        = number
  default     = 512
}
