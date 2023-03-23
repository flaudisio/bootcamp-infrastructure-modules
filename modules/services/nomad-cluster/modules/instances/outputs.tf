# ------------------------------------------------------------------------------
# ASG
# ------------------------------------------------------------------------------

output "asg_name" {
  description = "The name of the auto scaling group"
  value       = module.asg.autoscaling_group_name
}
