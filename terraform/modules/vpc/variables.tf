variable "environment" {
  description = "Nombre del entorno (dev/prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Lista de CIDRs para subredes públicas"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Lista de CIDRs para subredes privadas"
  type        = list(string)
}

variable "azs" {
  description = "Lista de Availability Zones"
  type        = list(string)
}