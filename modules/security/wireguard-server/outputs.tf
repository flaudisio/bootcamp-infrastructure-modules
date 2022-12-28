output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.ec2_instance.id
}

output "instance_private_dns" {
  description = "The private DNS of the EC2 instance"
  value       = aws_route53_record.instance_private.fqdn
}

output "instance_private_ip" {
  description = "The private IP of the EC2 instance"
  value       = module.ec2_instance.private_ip
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

output "vpn_public_endpoint_for_clients" {
  description = "The VPN public endpoint for clients. Use it for the initial setup of WG Portal"
  value       = format("%s:%s", aws_route53_record.public_endpoint.fqdn, var.wireguard_port)
}

output "vpn_portal_admin_password_ssm_parameter" {
  description = "The name of the SSM parameter that stores the VPN public key"
  value       = aws_ssm_parameter.wg_portal_admin_password.name
}

output "vpn_portal_endpoint" {
  description = "The WireGuard Portal endpoint for configuring the VPN service and clients"
  value       = format("https://%s", aws_route53_record.public_endpoint.fqdn)
}
