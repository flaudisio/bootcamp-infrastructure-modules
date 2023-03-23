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

variable "ec2_instance_count" {
  description = "The number of EC2 instances to launch"
  type        = number
  default     = 1
}

variable "ec2_instance_type" {
  description = "The type of the EC2 instance"
  type        = string
}

variable "ec2_ami_name" {
  description = "The name of the AMI used to deploy the EC2 instances"
  type        = string
  default     = "ubuntu-base-22.04-*"
}

variable "ec2_ami_owner" {
  description = "The owner of the AMI used to deploy the EC2 instances"
  type        = string
  default     = "self"
}

variable "ec2_ami_architecture" {
  description = "The architecture of the AMI used to deploy the EC2 instances"
  type        = string
  default     = "x86_64"
}

variable "ec2_public_key" {
  description = "The SSH public key material to be configured in the EC2 instance"
  type        = string
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
