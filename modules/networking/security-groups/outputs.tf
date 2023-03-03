output "semaphore_server_security_group" {
  description = "The ID of the security group to be attached to Ansible Semaphore server"
  value       = module.semaphore_server_security_group.security_group_id
}

output "semaphore_access_security_group" {
  description = "The ID of the security group to be attached to instances to enable access from Ansible Semaphore server"
  value       = module.semaphore_access_security_group.security_group_id
}

output "prometheus_server_security_group" {
  description = "The ID of the security group to be attached to Prometheus server"
  value       = module.semaphore_server_security_group.security_group_id
}

output "prometheus_scrape_security_group" {
  description = "The ID of the security group to be attached to instances to enable scraping from Prometheus server"
  value       = module.semaphore_access_security_group.security_group_id
}
