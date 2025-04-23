output "instance_ids" {
  value = aws_instance.app[*].id
}

output "security_group_id" {
  value = aws_security_group.ec2.id
}