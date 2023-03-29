# ------------------------------------------------------------------------------
# CLUSTER
# ------------------------------------------------------------------------------

output "cluster_security_group" {
  description = "The name of the cluster intra communication security group"
  value       = module.cluster_security_group.security_group_id
}

# ------------------------------------------------------------------------------
# SERVERS
# ------------------------------------------------------------------------------

output "server_asg_name" {
  description = "The name of the server auto scaling group"
  value       = module.server_instances.asg_name
}

# ------------------------------------------------------------------------------
# CLIENTS
# ------------------------------------------------------------------------------

output "client_asg_names" {
  description = "The names of the clients' auto scaling groups"
  value       = values(module.client_instances)[*].asg_name
}
