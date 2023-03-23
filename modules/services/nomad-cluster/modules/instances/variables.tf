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

variable "owner" {
  description = "The team that owns this WordPress site"
  type        = string
}

variable "private_subnets" {
  description = "A list of private subnet IDs to deploy the instances to"
  type        = list(string)
}

variable "key_name" {
  description = "The name of the key pair to be associated to instances"
  type        = string
}

variable "security_groups" {
  description = "A list of security groups to be attached to the instances"
  type        = list(string)
  default     = []
}

variable "service_name" {
  description = "The service name to identify resources"
  type        = string
}

variable "service_role" {
  description = "The Ansible service role to be used to configure instances"
  type        = string
}

variable "instance_count" {
  description = "The number of EC2 instances to launch"
  type        = number
}

variable "instance_type" {
  description = "The type of the EC2 instances"
  type        = string
}

variable "ami_name" {
  description = "The name of the AMI used to deploy the EC2 instances"
  type        = string
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

variable "root_volume_size" {
  description = "The size of the root EBS volume attached to instances"
  type        = number
}
