output "vpc_id" {
  value = aws_vpc.main.id
}

output "dmz_subnet_ids" {
  value = aws_subnet.dmz[*].id
}

output "dmz_subnet_id" {
  value = aws_subnet.dmz[0].id
}

output "private_ec2_subnet_ids" {
  value = aws_subnet.private_ec2[*].id
}

output "private_rds_subnet_ids" {
  value = aws_subnet.private_rds[*].id
}

output "route_table_id" {
  description = "ID de la tabla de rutas principal"
  value       = aws_route_table.main.id
}

output "vpc_cidr" {
  description = "El bloque CIDR de la VPC"
  value       = var.vpc_cidr
}