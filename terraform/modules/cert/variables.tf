variable "apache_vhost_name" {
  description = "El nombre de dominio para el certificado (p.ej. devDomain.com)"
  type        = string
}

variable "tags" {
  description = "Tags opcionales para recursos"
  type        = map(string)
  default     = {}
}
