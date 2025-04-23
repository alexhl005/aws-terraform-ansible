output "vpc_id" {
  value = aws_vpc.main.id
}

output "dmz_subnet_ids" {
  value = aws_subnet.dmz[*].id
}

output "private_ec2_subnet_ids" {
  value = aws_subnet.private_ec2[*].id
}

output "private_rds_subnet_ids" {
  value = aws_subnet.private_rds[*].id
}