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

variable "instance_type" {
  description = "The type of the EC2 instance"
  type        = string
}

variable "ami_name" {
  description = "The name of the AMI to be used for the instance"
  type        = string
  default     = "ubuntu-minimal/images/*ubuntu-jammy-22.04-*-minimal-20221208"
}

variable "ami_owner" {
  description = "The owner of the AMI to be used for the instance"
  type        = string
  default     = "099720109477" # Canonical
}

variable "public_key" {
  description = "The SSH public key material to be configured in the EC2 instance"
  type        = string
}

variable "allow_ssh_from_cidrs" {
  description = "A list of CIDRs to be allowed to access the SSH port of the instance"
  type        = list(string)
  default     = []
}