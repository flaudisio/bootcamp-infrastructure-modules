# ------------------------------------------------------------------------------
# APPLICATION
# ------------------------------------------------------------------------------

output "semaphore_endpoint" {
  description = "The endpoint of the Semaphore server"
  value       = format("https://%s", aws_route53_record.load_balancer.fqdn)
}

output "semaphore_credentials_ssm_parameters" {
  description = "The SSM parameters that store Semaphore credentials"
  value       = values(aws_ssm_parameter.semaphore_credentials)[*].name
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
