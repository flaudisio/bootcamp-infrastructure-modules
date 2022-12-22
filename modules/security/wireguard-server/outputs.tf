output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.ec2_instance.id
}

output "instance_public_dns" {
  description = "The public DNS of the EC2 instance"
  value       = aws_eip.this.public_dns
}

output "instance_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_eip.this.public_ip
}

output "security_group_id" {
  description = "The ID of the instance's security group"
  value       = module.security_group.security_group_id
}

output "vpn_endpoint" {
  description = "The VPN endpoint to be configured in the client's `wg0.conf` file"
  value       = format("%s:%s", aws_route53_record.vpn_endpoint.fqdn, var.wireguard_port)
}

output "vpn_public_key_ssm_parameter" {
  description = "The name of the SSM parameter that stores the VPN public key"
  value       = aws_ssm_parameter.vpn_public_key.name
}
