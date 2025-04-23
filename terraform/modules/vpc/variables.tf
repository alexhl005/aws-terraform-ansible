variable "environment" {
  description = "Nombre del entorno (dev/prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
}

variable "dmz_subnet_cidr" {
  description = "CIDR para subredes públicas"
  type        = string
}

variable "private_ec2_subnet_cidr" {
  description = "CIDR para subredes privadas EC2s"
  type        = string
}

variable "private_rds_subnet_cidr" {
  description = "CIDR para subredes privadas RDSs"
  type        = string
}

variable "azs" {
  description = "Lista de Availability Zones"
  type        = list(string)
}