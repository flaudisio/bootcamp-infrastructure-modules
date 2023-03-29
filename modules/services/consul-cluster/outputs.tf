# ------------------------------------------------------------------------------
# APPLICATION
# ------------------------------------------------------------------------------

output "consul_endpoint" {
  description = "The endpoint of the Consul cluster"
  value       = format("https://%s", aws_route53_record.load_balancer.fqdn)
}

# ------------------------------------------------------------------------------
# LOAD BALANCER
# ------------------------------------------------------------------------------

output "lb_dns_name" {
  description = "The name of the cluster load balancer"
  value       = module.load_balancer.lb_dns_name
}
