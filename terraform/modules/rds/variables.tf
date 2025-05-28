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

variable "ec2_security_group_id" {
  description = "ID del security group de EC2 que puede acceder al RDS"
  type        = string
}

variable "allocated_storage" {
  description = "Almacenamiento asignado para la base de datos"
  type        = number
}