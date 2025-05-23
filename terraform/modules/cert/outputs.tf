output "certificate_arn" {
  description = "ARN del certificado ACM validado"
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "certificate_domain" {
  description = "Dominio del certificado"
  value       = aws_acm_certificate.this.domain_name
}
