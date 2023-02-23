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

variable "public_subnets" {
  description = "A list of public subnet IDs to deploy the load balancer to"
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnet IDs to deploy the instances to"
  type        = list(string)
}

variable "allow_vpc_access" {
  description = "Whether to allow any VPC-originating access to private resources. Only enable for debugging purposes!"
  type        = bool
  default     = false
}

variable "site_name" {
  description = "The name of the site"
  type        = string
}

variable "asg_min_size" {
  description = "The minimum site of the auto scaling group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "The maximum site of the auto scaling group"
  type        = number
  default     = 1
}

variable "asg_desired_capacity" {
  description = "The desired capacity of the auto scaling group"
  type        = number
  default     = 1
}

variable "asg_health_check_type" {
  description = "The mode the ASG health checking is done"
  type        = string
  default     = "ELB"
}

variable "ec2_instance_type" {
  description = "The type of the EC2 instances"
  type        = string
}

variable "ec2_ami_name" {
  description = "The name of the AMI used to deploy the EC2 instances"
  type        = string
  default     = "ubuntu-minimal/images/*ubuntu-jammy-22.04-*-minimal-20230213"
}

variable "ec2_ami_owner" {
  description = "The owner of the AMI used to deploy the EC2 instances"
  type        = string
  default     = "099720109477" # Canonical
}

variable "ec2_ami_architecture" {
  description = "The architecture of the AMI used to deploy the EC2 instances"
  type        = string
  default     = "x86_64"
}

variable "ec2_public_key" {
  description = "The SSH public key material to be configured in EC2 instances"
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

variable "memcached_instance_type" {
  description = "The type of the ElastiCache/Memcached instance"
  type        = string
}

variable "memcached_multi_az" {
  description = "Whether the Memcached nodes should be created across multiple AZs. Requires `memcached_num_nodes > 1`"
  type        = bool
  default     = false
}

variable "memcached_num_nodes" {
  description = "The initial number of cache nodes that the cache cluster will have; must be between 1 and 40. If this number is reduced on subsequent runs, the highest numbered nodes will be removed"
  type        = number
  default     = 1
}

variable "memcached_subnet_group" {
  description = "The name of the ElastiCache subnet group to be used by the Memcached cluster"
  type        = string
}
