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

variable "public_subnet_id" {
  description = "The ID of the public subnet where the instance will be deployed on"
  type        = string
}

variable "instance_type" {
  description = "The type of the EC2 instance"
  type        = string

  validation {
    condition     = can(regex("^t4g\\.", var.instance_type))
    error_message = "You must use a 't4g' instance."
  }
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

variable "wireguard_port" {
  description = "The port where the WireGuard server will listen to"
  type        = number
  default     = 51820
}

variable "allow_ssh_from_cidrs" {
  description = "A list of CIDRs to be allowed to access the SSH port of the instance"
  type        = list(string)
  default     = []
}