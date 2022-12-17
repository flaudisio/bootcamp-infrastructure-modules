output "zone_arn" {
  description = "The ARN of the zone"
  value       = aws_route53_zone.this.arn
}

output "zone_id" {
  description = "The ID of the zone"
  value       = aws_route53_zone.this.zone_id
}

output "zone_name" {
  description = "The name of the zone"
  value       = aws_route53_zone.this.name
}

output "zone_name_servers" {
  description = "The list of name servers of the zone"
  value       = aws_route53_zone.this.name_servers
}
