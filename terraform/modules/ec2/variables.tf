variable "environment" {
  description = "Nombre del entorno (dev/prod)"
  type        = string
}

variable "key_name" {
  description = "Clave para ssh"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "subnet_ids" {
  description = "IDs de las subredes"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID para las instancias"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia"
  type        = string
  default     = "t3.medium"
}

variable "instance_count" {
  description = "Número de instancias"
  type        = number
  default     = 2
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs permitidos para SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "dmz_subnet_id" {
  description = "Subnet pública (DMZ) donde estará el bastión"
  type        = string
}

variable "bastion_allowed_cidr" {
  description = "CIDR desde el que el bastión aceptará SSH"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR de la VPC para las reglas de egress del SG del bastión"
  type        = string
}
