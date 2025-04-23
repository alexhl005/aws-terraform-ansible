variable "vpc_id" {
  description = "ID of the VPC where the ELB will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the ELB will be deployed"
  type        = list(string)
}