# 1. Creamos la Hosted Zone pública
resource "aws_route53_zone" "primary" {
  name    = var.domain_name
  comment = "Zona Route 53 para el dominio ${var.domain_name}"
}

# 2. Generamos el certificado en ACM con validación DNS
resource "aws_acm_certificate" "site" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  tags              = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# 3. Creamos los registros DNS de validación usando la zona creada
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.site.domain_validation_options :
    dvo.domain_name => dvo
  }

  zone_id = aws_route53_zone.primary.zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  ttl     = 300
  records = [each.value.resource_record_value]
}

# 4. Esperamos a que ACM valide el certificado
resource "aws_acm_certificate_validation" "site" {
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for r in aws_route53_record.validation : r.fqdn]
}
