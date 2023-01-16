# ------------------------------------------------------------------------------
# APPLICATION
# ------------------------------------------------------------------------------

output "app_endpoint" {
  description = "The endpoint of the application"
  value       = format("https://%s", aws_route53_record.load_balancer.fqdn)
}

# ------------------------------------------------------------------------------
# LOAD BALANCER
# ------------------------------------------------------------------------------

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.load_balancer.lb_dns_name
}

# ------------------------------------------------------------------------------
# ASG
# ------------------------------------------------------------------------------

output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = module.asg.autoscaling_group_name
}

# ------------------------------------------------------------------------------
# RDS
# ------------------------------------------------------------------------------

output "db_address" {
  description = "The address of the database instance"
  value       = aws_route53_record.rds.fqdn
}

output "db_endpoint" {
  description = "The endpoint of the database instance"
  value       = format("%s:%s", aws_route53_record.rds.fqdn, module.rds.db_instance_port)
}

# ------------------------------------------------------------------------------
# MEMCACHED
# ------------------------------------------------------------------------------

output "memcached_address" {
  description = "The DNS name of the Memcached cluster without the port appended"
  value       = aws_route53_record.memcached.fqdn
}

output "memcached_endpoint" {
  description = "The endpoint of the Memcached cluster"
  value       = format("%s:%s", aws_route53_record.memcached.fqdn, module.memcached.cluster_port)
}

# ------------------------------------------------------------------------------
# S3
# ------------------------------------------------------------------------------

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_id
}
