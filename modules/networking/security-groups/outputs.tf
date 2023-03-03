output "semaphore_server_security_group" {
  description = "The ID of the security group to be attached to Ansible Semaphore server"
  value       = module.semaphore_server_security_group.security_group_id
}

output "prometheus_server_security_group" {
  description = "The ID of the security group to be attached to Prometheus server"
  value       = module.semaphore_server_security_group.security_group_id
}

output "infra_services_security_group" {
  description = "The ID of the security group to be attached to instances to allow access from infrastructure services"
  value       = module.infra_services_security_group.security_group_id
}
