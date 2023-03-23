# ------------------------------------------------------------------------------
# TAGS
# ------------------------------------------------------------------------------

module "tags" {
  source  = "flaudisio/standard-tags/aws"
  version = "0.3.0"

  environment = var.environment
  owner       = "infra"
  service     = "core-infra"
}

# ------------------------------------------------------------------------------
# SEMAPHORE SERVER SECURITY GROUP
# ------------------------------------------------------------------------------

module "semaphore_server_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "semaphore-server-base"
  description = "Semaphore - base security group for Semaphore server instances"
  vpc_id      = var.vpc_id

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# PROMETHEUS SERVER SECURITY GROUP
# ------------------------------------------------------------------------------

module "prometheus_server_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "prometheus-server-base"
  description = "Prometheus - base security group for Prometheus server instances"
  vpc_id      = var.vpc_id

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# INFRA SERVICES SECURITY GROUP
# ------------------------------------------------------------------------------

module "infra_services_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "infra-services-access"
  description = "Allow infrastructure services to access instances"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      description              = "SSH access from Semaphore server"
      source_security_group_id = module.semaphore_server_security_group.security_group_id
    },
    {
      rule                     = "http-80-tcp"
      description              = "Prometheus scraping"
      source_security_group_id = module.prometheus_server_security_group.security_group_id
    },
    {
      rule                     = "http-8080-tcp"
      description              = "Prometheus scraping"
      source_security_group_id = module.prometheus_server_security_group.security_group_id
    },
    {
      rule                     = "https-443-tcp"
      description              = "Prometheus scraping"
      source_security_group_id = module.prometheus_server_security_group.security_group_id
    },
    {
      from_port                = 9404
      to_port                  = 9404
      protocol                 = "tcp"
      description              = "Prometheus scraping - CloudWatch agent"
      source_security_group_id = module.prometheus_server_security_group.security_group_id
    },
  ]

  tags = module.tags.tags
}
