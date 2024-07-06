output "domain_name" {
  description = "domain name"
  value       = values(module.zones.route53_zone_name)[0]
}

output "zone_id" {
  description = "zone id"
  value       = values(module.zones.route53_zone_zone_id)[0]
}

output "private_zone_id" {
  description = "zone id"
  value       = aws_route53_zone.private.zone_id
}
