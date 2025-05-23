variable "domain_name" {
  description = "El nombre de dominio para el certificado ACM (p.ej. devDomain.com)"
  type        = string
}

variable "tags" {
  description = "Tags opcionales para los recursos"
  type        = map(string)
  default     = {}
}
