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

variable "instance_count" {
  description = "The number of EC2 instances to launch"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "The type of the EC2 instances"
  type        = string
}

variable "ami_name" {
  description = "The name of the AMI used to deploy the EC2 instances"
  type        = string
  default     = "ubuntu-base-22.04-*"
}

variable "ami_owner" {
  description = "The owner of the AMI used to deploy the EC2 instances"
  type        = string
  default     = "self"
}

variable "ami_architecture" {
  description = "The architecture of the AMI used to deploy the EC2 instances"
  type        = string
  default     = "x86_64"
}

variable "public_key" {
  description = "The SSH public key material to be configured in EC2 instances"
  type        = string
}
