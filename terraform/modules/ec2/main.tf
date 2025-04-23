resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(var.subnet_ids, count.index)
  vpc_security_group_ids = [aws_security_group.ec2.id]
  associate_public_ip_address = false
  key_name      = var.key_name # si quieres acceder por SSH

  tags = {
    Name = "${var.environment}-web-${count.index + 1}"
  }
}

resource "aws_security_group" "ec2" {
  vpc_id      = var.vpc_id
  name        = "${var.environment}-ec2-sg"
  description = "Allow HTTP/HTTPS from ELB and SSH from allowed CIDRs"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidrs  # Asegúrate de que var.ssh_allowed_cidrs esté restringido
  }

  ingress {
    description = "HTTP from ELB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Esto está bien para tráfico web desde el ELB
  }

  ingress {
    description = "HTTPS from ELB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Esto está bien para tráfico web desde el ELB
  }

  # PostgreSQL no debe abrirse aquí, sino en el SG de RDS (en el SG de EC2 es innecesario)
  # De todas formas, si es necesario para alguna comunicación interna entre EC2 y RDS, usa el SG de RDS.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}