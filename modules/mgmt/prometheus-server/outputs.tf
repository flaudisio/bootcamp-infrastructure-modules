# ------------------------------------------------------------------------------
# ASG
# ------------------------------------------------------------------------------

output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = module.asg.autoscaling_group_name
}

output "asg_security_group_id" {
  description = "The ID of the security group attached to the EC2 instances"
  value       = module.asg_security_group.security_group_id
}

# ------------------------------------------------------------------------------
# TIMESTREAM
# ------------------------------------------------------------------------------

output "timestream_database_arn" {
  description = "The ARN of the Timestream database"
  value       = aws_timestreamwrite_database.this.arn
}

output "timestream_database_name" {
  description = "The name of the Timestream database"
  value       = aws_timestreamwrite_database.this.database_name
}

output "timestream_table_arn" {
  description = "The ARN of the Timestream table"
  value       = aws_timestreamwrite_table.this.arn
}

output "timestream_table_name" {
  description = "The name of the Timestream table"
  value       = aws_timestreamwrite_table.this.table_name
}
