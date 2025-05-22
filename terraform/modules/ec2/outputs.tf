output "instance_ids" {
  value = aws_instance.web[*].id
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2.id
}

output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "IP pública del bastión SSH"
}
