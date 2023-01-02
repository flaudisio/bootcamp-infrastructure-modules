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

variable "cidr" {
  description = "The CIDR of the VPC"
  type        = string

  validation {
    condition     = can(regex("^10\\.[0-9]+\\.0\\.0/16$", var.cidr))
    error_message = "The VPC CIDR must use the '10.XXX.0.0/16' format."
  }
}

variable "single_nat_gateway" {
  description = "Whether to provision a single shared NAT Gateway across all of the private networks"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Whether to provision only one NAT Gateway per availability zone"
  type        = bool
  default     = true
}
