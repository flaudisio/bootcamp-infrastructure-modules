output "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = module.ecs_cluster.cluster_id
}

output "ecs_service" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.this.name
}
