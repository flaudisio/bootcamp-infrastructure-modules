# ------------------------------------------------------------------------------
# ACCOUNT ALIAS
# ------------------------------------------------------------------------------

resource "aws_iam_account_alias" "this" {
  account_alias = var.account_name
}

# ------------------------------------------------------------------------------
# S3 ACCOUNT PUBLIC ACCESS BLOCK
# ------------------------------------------------------------------------------

resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
