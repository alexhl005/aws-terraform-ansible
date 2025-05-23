# 1. Obtenemos la zona DNS en Route 53 (ajusta el nombre a tu dominio)
data "aws_route53_zone" "primary" {
  name         = var.apache_vhost_name
  private_zone = false
}

# 2. Creamos el certificado en ACM, con validación DNS
resource "aws_acm_certificate" "site" {
  domain_name       = var.apache_vhost_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# 3. Generamos el registro DNS para validar el cert
resource "aws_route53_record" "cert_validation" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = aws_acm_certificate.site.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.site.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.site.domain_validation_options[0].resource_record_value]
  ttl     = 300
}

# 4. Esperamos a que ACM confirme la validación
resource "aws_acm_certificate_validation" "site" {
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}
