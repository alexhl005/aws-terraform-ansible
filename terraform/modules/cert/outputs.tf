output "hosted_zone_id" {
  description = "ID de la Hosted Zone recién creada"
  value       = aws_route53_zone.primary.zone_id
}

output "certificate_arn" {
  description = "ARN del certificado ACM validado"
  value       = aws_acm_certificate_validation.site.certificate_arn
}

output "certificate_domain" {
  description = "Dominio del certificado ACM"
  value       = aws_acm_certificate.site.domain_name
}
