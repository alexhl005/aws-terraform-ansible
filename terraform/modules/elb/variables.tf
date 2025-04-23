variable "environment" {
  description = "Nombre del entorno (dev/prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the ELB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of subnet IDs where the ELB will be deployed"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN del certificado SSL de ACM para el Load Balancer"
  type        = string
}
