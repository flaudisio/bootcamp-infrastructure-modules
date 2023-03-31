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
  description = "A list of security groups to be attached to the instances"
  type        = list(string)
  default     = []
}

variable "allow_vpc_access" {
  description = "Whether to allow any VPC-originating access to private resources. Only enable for debugging purposes!"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "The name of the Nomad cluster"
  type        = string
}

variable "cluster_public_key" {
  description = "The SSH public key material to be configured in all EC2 instances of the cluster"
  type        = string
}

variable "server_instance_type" {
  description = "The type of the server instances"
  type        = string
}

variable "server_instance_count" {
  description = "The number of server instances"
  type        = number
  default     = 3

  validation {
    condition     = contains(range(1, 8), var.server_instance_count)
    error_message = "The number of servers must be between 1 and 7."
  }
}

variable "server_root_volume_size" {
  description = "The size of the root EBS volume attached to server instances"
  type        = number
  default     = 30
}

variable "server_ami_name" {
  description = "The name of the AMI used to deploy the server instances"
  type        = string
  default     = "ubuntu-base-22.04-*"
}

variable "server_ami_owner" {
  description = "The owner of the AMI used to deploy the server instances"
  type        = string
  default     = "self"
}

variable "server_ami_architecture" {
  description = "The architecture of the AMI used to deploy the server instances"
  type        = string
  default     = "x86_64"
}

variable "client_instance_groups" {
  description = "A map of objects describing the client instance groups to be created"
  type = map(object(
    {
      ami_name         = optional(string, "ubuntu-base-22.04-*")
      ami_owner        = optional(string, "self")
      architecture     = optional(string, "x86_64")
      instance_type    = string
      instance_count   = number
      root_volume_size = optional(number, 30)
    }
  ))
  default = {}
}
