# ------------------------------------------------------------------------------
# TAGS
# ------------------------------------------------------------------------------

module "tags" {
  source  = "flaudisio/standard-tags/aws"
  version = "0.3.0"

  environment = var.environment
  owner       = var.owner
  service     = var.service
}

# ------------------------------------------------------------------------------
# LOCALS
# ------------------------------------------------------------------------------

locals {
  environment_part = var.append_environment ? "-${var.environment}" : ""
  account_id_part  = var.append_account_id ? "-${var.account_id}" : ""
  region_part      = var.append_region ? "-${var.aws_region}" : ""

  bucket_name = format("%s%s%s%s", var.bucket_name, local.environment_part, local.account_id_part, local.region_part)
}

# ------------------------------------------------------------------------------
# S3 BUCKET
# ------------------------------------------------------------------------------

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.7.0"

  bucket = local.bucket_name

  control_object_ownership = true
  object_ownership         = var.object_ownership

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = module.tags.tags
}
