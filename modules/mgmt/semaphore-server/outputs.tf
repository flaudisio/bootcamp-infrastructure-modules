output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.ec2_instance.id
}

output "instance_private_ip" {
  description = "The private IP of the EC2 instance"
  value       = module.ec2_instance.private_ip
}

output "security_group_id" {
  description = "The ID of the instance's security group"
  value       = module.ec2_security_group.security_group_id
}

output "semaphore_endpoint" {
  description = "The endpoint of the Semaphore server"
  value       = format("http://%s", aws_route53_record.endpoint.fqdn)
}

output "semaphore_credentials_ssm_parameters" {
  description = "The SSM parameters that store Semaphore credentials"
  value       = values(aws_ssm_parameter.semaphore_credentials)[*].name
}
