output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = module.s3_bucket.s3_bucket_arn
}

output "bucket_name" {
  description = "The name of the bucket"
  value       = module.s3_bucket.s3_bucket_id
}

output "bucket_region" {
  description = "The region of the bucket"
  value       = module.s3_bucket.s3_bucket_region
}
