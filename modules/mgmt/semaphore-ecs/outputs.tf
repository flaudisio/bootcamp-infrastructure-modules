# ------------------------------------------------------------------------------
# APPLICATION
# ------------------------------------------------------------------------------

output "semaphore_endpoint" {
  description = "The endpoint of the Semaphore server"
  value       = local.semaphore_endpoint
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
# ECS
# ------------------------------------------------------------------------------

output "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = module.ecs_cluster.cluster_id
}

output "ecs_service" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.this.name
}
