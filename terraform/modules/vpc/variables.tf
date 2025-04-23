variable "environment" {
  description = "Nombre del entorno (dev/prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
}

variable "dmz_subnet_cidrs" {
  description = "Lista de CIDRs para subredes públicas"
  type        = list(string)
}

variable "private_ec2_subnet_cidrs" {
  description = "Lista de CIDRs para subredes privadas"
  type        = list(string)
}

variable "private_rds_subnet_cidrs" {
  description = "Lista de CIDRs para subredes privadas"
  type        = list(string)
}

variable "azs" {
  description = "Lista de Availability Zones"
  type        = list(string)
}