# Generar clave SSH para conexión
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${var.environment}-wp-key"
  public_key = tls_private_key.this.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.this.private_key_pem
  filename = "${path.module}/.ssh/${var.environment}-wp-key.pem"
  file_permission = "0600"
}

# Instancia EC2
resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(var.subnet_ids, count.index)
  vpc_security_group_ids = [aws_security_group.ec2.id]
  associate_public_ip_address = false
  key_name      = aws_key_pair.this.key_name

  # Configuración inicial
  user_data = <<-EOF
              #!/bin/bash
              # Crear estructura de directorios
              mkdir -p ~/scripts/{bash,monitoring,python}
              mkdir -p ~/scripts/bash/{backup,utilities}
              mkdir -p /opt/aws-monitoring
              EOF

  # Conexión SSH
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.this.private_key_pem
    host        = self.private_ip
  }

  # Copiar scripts - Manteniendo tu estructura de carpetas
  provisioner "file" {
    source      = "scripts/bash/backup/s3_sync.sh"
    destination = "~/scripts/bash/backup/s3_sync.sh"
  }

  provisioner "file" {
    source      = "scripts/monitoring/check_services.sh"
    destination = "~/scripts/monitoring/check_services.sh"
  }

  provisioner "file" {
    source      = "scripts/monitoring/log_analyzer.sh"
    destination = "~/scripts/monitoring/log_analyzer.sh"
  }

  provisioner "file" {
    source      = "scripts/bash/utilities/cleanup.sh"
    destination = "~/scripts/bash/utilities/cleanup.sh"
  }

  provisioner "file" {
    source      = "scripts/bash/utilities/security_audit.sh"
    destination = "~/scripts/bash/utilities/security_audit.sh"
  }

  provisioner "file" {
    source      = "scripts/bash/utilities/weekly_maintenance.sh"
    destination = "~/scripts/bash/utilities/weekly_maintenance.sh"
  }

  provisioner "file" {
    source      = "scripts/python/cloudwatch/cloudwatch_alerts.py"
    destination = "/opt/aws-monitoring/cloudwatch_alerts.py"
  }

  provisioner "file" {
    source      = "scripts/python/slack_reporter.py"
    destination = "~/scripts/python/slack_reporter.py"
  }

  provisioner "file" {
    source      = "scripts/python/cloudwatch/cloudwatch-metrics.service"
    destination = "/tmp/cloudwatch-metrics.service"
  }

  # Configuración final vía SSH
  provisioner "remote-exec" {
    inline = [
      # Establecer permisos
      "chmod +x ~/scripts/bash/backup/s3_sync.sh",
      "chmod +x ~/scripts/monitoring/check_services.sh",
      "chmod +x ~/scripts/monitoring/log_analyzer.sh",
      "chmod +x ~/scripts/bash/utilities/cleanup.sh",
      "chmod +x ~/scripts/bash/utilities/security_audit.sh",
      "chmod +x ~/scripts/bash/utilities/weekly_maintenance.sh",
      "chmod +x /opt/aws-monitoring/cloudwatch_alerts.py",
      "chmod +x ~/scripts/python/slack_reporter.py",

      # Configurar servicio CloudWatch
      "sudo mv /tmp/cloudwatch-metrics.service /etc/systemd/system/",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable cloudwatch-metrics",
      "sudo systemctl start cloudwatch-metrics",

      # Instalar dependencias Python
      "sudo apt-get update",
      "sudo apt-get install -y python3-pip",
      "sudo pip3 install boto3 psutil requests",

      # Configurar cronjobs
      "(crontab -l 2>/dev/null; echo \"59 23 * * 0 /home/ubuntu/scripts/bash/backup/s3_sync.sh\") | crontab -",
      "(crontab -l 2>/dev/null; echo \"*/5 * * * * /home/ubuntu/scripts/monitoring/check_services.sh\") | crontab -",
      "(crontab -l 2>/dev/null; echo \"0 1 * * * /home/ubuntu/scripts/monitoring/log_analyzer.sh\") | crontab -",
      "(crontab -l 2>/dev/null; echo \"0 0 * * * /home/ubuntu/scripts/bash/utilities/cleanup.sh\") | crontab -",
      "(crontab -l 2>/dev/null; echo \"0 12 * * 1 /home/ubuntu/scripts/bash/utilities/security_audit.sh\") | crontab -",
      "(crontab -l 2>/dev/null; echo \"0 3 * * 0 /home/ubuntu/scripts/bash/utilities/weekly_maintenance.sh\") | crontab -"
    ]
  }

  tags = {
    Name = "${var.environment}-web-${count.index + 1}"
  }
}

# Guardar la IP privada para referencia
output "instance_private_ips" {
  value = aws_instance.web[*].private_ip
}

# Guardar el comando SSH de ejemplo
output "ssh_command" {
  value = format("ssh -i .ssh/%s-wp-key.pem ubuntu@%s", var.environment, aws_instance.web[0].private_ip)
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