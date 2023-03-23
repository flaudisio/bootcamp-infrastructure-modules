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
# ROUTE 53 ZONE
# ------------------------------------------------------------------------------

resource "aws_route53_zone" "this" {
  name = var.zone_name

  tags = module.tags.tags
}
