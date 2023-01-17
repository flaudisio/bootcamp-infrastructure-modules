# ------------------------------------------------------------------------------
# TAGS
# ------------------------------------------------------------------------------

module "tags" {
  source  = "flaudisio/standard-tags/aws"
  version = "0.1.1"

  environment = var.environment
  service     = "core-infra"
  owner       = "infra"
}

# ------------------------------------------------------------------------------
# ROUTE 53 ZONE
# ------------------------------------------------------------------------------

resource "aws_route53_zone" "this" {
  name = var.zone_name

  tags = module.tags.tags
}
