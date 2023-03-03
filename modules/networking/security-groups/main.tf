# ------------------------------------------------------------------------------
# TAGS
# ------------------------------------------------------------------------------

module "tags" {
  source  = "flaudisio/standard-tags/aws"
  version = "0.2.0"

  environment = var.environment
  service     = "core-infra"
  owner       = "infra"
}

# ------------------------------------------------------------------------------
# SEMAPHORE SECURITY GROUPS
# ------------------------------------------------------------------------------

module "semaphore_server_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "semaphore-server-base"
  description = "Semaphore - base security group for Semaphore server instances"
  vpc_id      = var.vpc_id

  tags = module.tags.tags
}

module "semaphore_access_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "semaphore-access"
  description = "Semaphore - allow Semaphore server to access clients"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      description              = "SSH from Semaphore server"
      source_security_group_id = module.semaphore_server_security_group.security_group_id
    },
  ]

  tags = module.tags.tags
}

# ------------------------------------------------------------------------------
# PROMETHEUS SECURITY GROUPS
# ------------------------------------------------------------------------------

module "prometheus_server_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "prometheus-server-base"
  description = "Prometheus - base security group for Prometheus server instances"
  vpc_id      = var.vpc_id

  tags = module.tags.tags
}

module "prometheus_scrape_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "prometheus-scrape"
  description = "Prometheus - allow Prometheus server to scrape metrics"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
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
      description              = "Prometheus scraping"
      source_security_group_id = module.prometheus_server_security_group.security_group_id
    },
  ]

  tags = module.tags.tags
}
