variable "environment" {
  description = "Nombre del entorno (dev/prod)"
  type        = string 
}

variable "domain_name" {
  description = "El nombre de dominio para el certificado"
  type        = string
}

variable "apache_vhost_name" {
  description = "Variable para el nombre de dominio"
  type        = string
}

variable "tags" {
  description = "Tags opcionales para recursos"
  type        = map(string)
  default     = {}
}
