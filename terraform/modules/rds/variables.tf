variable "environment" {
  description = "Nombre del entorno (dev/prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs de las subredes privadas"
  type        = list(string)
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "ecommerce"
}

variable "db_username" {
  description = "Usuario maestro de RDS"
  type        = string
}

variable "db_password" {
  description = "Contraseña para el usuario maestro"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "Tipo de instancia RDS"
  type        = string
  default     = "db.t3.medium"
}

variable "multi_az" {
  description = "Habilitar Multi-AZ"
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = "CIDRs permitidos para acceder a RDS"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}