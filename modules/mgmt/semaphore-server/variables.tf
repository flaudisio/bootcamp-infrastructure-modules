# ------------------------------------------------------------------------------
# COMMON VARIABLES
# ------------------------------------------------------------------------------

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

variable "private_subnet_id" {
  description = "The ID of the private subnet where the instance will be deployed on"
  type        = string
}

variable "attach_security_groups" {
  description = "A list security groups to be attached to the instance"
  type        = list(string)
  default     = []
}

variable "allow_ssh_from_vpc" {
  description = "Whether to allow SSH access from any hosts in the VPC. Only enable for debugging purposes!"
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "The type of the EC2 instance"
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
  description = "The SSH public key material to be configured in the EC2 instance"
  type        = string
}
