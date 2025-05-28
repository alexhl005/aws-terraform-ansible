# 1. Clave SSH para conexión
resource "tls_private_key" "key_pars" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pars" {
  key_name   = "${var.environment}-wp-key"
  public_key = tls_private_key.key_pars.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.key_pars.private_key_pem
  filename        = "~/.ssh/${var.environment}-wp-key.pem"
  file_permission = "0600"
}

# 2. Bastión
resource "aws_security_group" "bastion" {
  name        = "${var.environment}-bastion-sg"
  description = "SSH acceso externo y hacia EC2 internas"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH desde IP externa"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_allowed_cidr]
  }

  egress {
    description = "SSH hacia red interna"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = { Name = "${var.environment}-bastion-sg" }
}

resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  subnet_id                   = var.dmz_subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key_pars.key_name
  tags = { Name = "${var.environment}-bastion" }
}

# 3. SG para Web
resource "aws_security_group" "ec2" {
  vpc_id = var.vpc_id
  name   = "${var.environment}-ec2-sg"
  description = "Allow HTTP/HTTPS from ELB and SSH from bastion"

  ingress {
    description      = "SSH from bastion"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [aws_security_group.bastion.id]
  }
  ingress {
    description = "HTTP from ELB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS from ELB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.environment}-ec2-sg" }
}

# 4. Web servers
resource "aws_instance" "web" {
  count                       = var.instance_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = element(var.subnet_ids, count.index)
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = false
  key_name                    = aws_key_pair.key_pars.key_name

  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /home/ubuntu/scripts/bash/backup
    mkdir -p /home/ubuntu/scripts/bash/utilities
    mkdir -p /home/ubuntu/scripts/monitoring
    mkdir -p /home/ubuntu/scripts/python/cloudwatch
    mkdir -p /opt/aws-monitoring
  EOF

  connection {
    type               = "ssh"
    user               = "ubuntu"
    private_key        = tls_private_key.key_pars.private_key_pem
    host               = self.private_ip

    bastion_host       = aws_instance.bastion.public_ip
    bastion_user       = "ubuntu"
    bastion_private_key= tls_private_key.key_pars.private_key_pem
  }

  # 4.1 Asegurar directorios antes de copiar
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /home/ubuntu/scripts/bash/backup",
      "sudo mkdir -p /home/ubuntu/scripts/bash/utilities",
      "sudo mkdir -p /home/ubuntu/scripts/monitoring",
      "sudo mkdir -p /home/ubuntu/scripts/python/cloudwatch",
      "sudo mkdir -p /opt/aws-monitoring",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/scripts /opt/aws-monitoring"
    ]
  }

  # 4.2 Copiar scripts
  provisioner "file" {
    source      = "/var/lib/jenkins/workspace/aws-terraform-ansible/scripts/bash/backup/s3_sync.sh"
    destination = "/home/ubuntu/scripts/bash/backup/s3_sync.sh"
  }
  provisioner "file" {
    source      = "/var/lib/jenkins/workspace/aws-terraform-ansible/scripts/bash/monitoring/check_services.sh"
    destination = "/home/ubuntu/scripts/monitoring/check_services.sh"
  }
  provisioner "file" {
    source      = "/var/lib/jenkins/workspace/aws-terraform-ansible/scripts/bash/monitoring/log_analyzer.sh"
    destination = "/home/ubuntu/scripts/monitoring/log_analyzer.sh"
  }
  provisioner "file" {
    source      = "/var/lib/jenkins/workspace/aws-terraform-ansible/scripts/bash/utilities/cleanup.sh"
    destination = "/home/ubuntu/scripts/bash/utilities/cleanup.sh"
  }
  provisioner "file" {
    source      = "/var/lib/jenkins/workspace/aws-terraform-ansible/scripts/bash/utilities/security_audit.sh"
    destination = "/home/ubuntu/scripts/bash/utilities/security_audit.sh"
  }
  provisioner "file" {
    source      = "/var/lib/jenkins/workspace/aws-terraform-ansible/scripts/bash/utilities/weekly_maintenance.sh"
    destination = "/home/ubuntu/scripts/bash/utilities/weekly_maintenance.sh"
  }
  provisioner "file" {
    source      = "/var/lib/jenkins/workspace/aws-terraform-ansible/scripts/python/cloudwatch/cloudwatch_alerts.py"
    destination = "/opt/aws-monitoring/cloudwatch_alerts.py"
  }
  provisioner "file" {
    source      = "/var/lib/jenkins/workspace/aws-terraform-ansible/scripts/python/slack_reporter.py"
    destination = "/home/ubuntu/scripts/python/slack_reporter.py"
  }
  provisioner "file" {
    source      = "/var/lib/jenkins/workspace/aws-terraform-ansible/scripts/python/cloudwatch/cloudwatch-metrics.service"
    destination = "/tmp/cloudwatch-metrics.service"
  }

  # 4.3 Pasos finales
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ubuntu/scripts/bash/backup/s3_sync.sh",
      "sudo chmod +x /home/ubuntu/scripts/monitoring/check_services.sh",
      "sudo chmod +x /home/ubuntu/scripts/monitoring/log_analyzer.sh",
      "sudo chmod +x /home/ubuntu/scripts/bash/utilities/cleanup.sh",
      "sudo chmod +x /home/ubuntu/scripts/bash/utilities/security_audit.sh",
      "sudo chmod +x /home/ubuntu/scripts/bash/utilities/weekly_maintenance.sh",
      "sudo chmod +x /opt/aws-monitoring/cloudwatch_alerts.py",
      "sudo chmod +x /home/ubuntu/scripts/python/slack_reporter.py",
      "sudo mv /tmp/cloudwatch-metrics.service /etc/systemd/system/",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable cloudwatch-metrics",
      "sudo systemctl start cloudwatch-metrics",
      "sudo apt-get update",
      "sudo apt-get install -y python3-pip",
      "sudo pip install boto3 psutil requests",
      "(crontab -l; echo \"59 23 * * 0 /home/ubuntu/scripts/bash/backup/s3_sync.sh\") | crontab -",
      "(crontab -l; echo \"*/5 * * * * /home/ubuntu/scripts/monitoring/check_services.sh\") | crontab -",
      "(crontab -l; echo \"0 1 * * * /home/ubuntu/scripts/monitoring/log_analyzer.sh\") | crontab -",
      "(crontab -l; echo \"0 0 * * * /home/ubuntu/scripts/bash/utilities/cleanup.sh\") | crontab -",
      "(crontab -l; echo \"0 12 * * 1 /home/ubuntu/scripts/bash/utilities/security_audit.sh\") | crontab -",
      "(crontab -l; echo \"0 3 * * 0 /home/ubuntu/scripts/bash/utilities/weekly_maintenance.sh\") | crontab -"
    ]
  }

  tags = { Name = "${var.environment}-web-${count.index + 1}" }
}

# 5. Outputs
output "instance_private_ips" {
  value       = aws_instance.web[*].private_ip
  description = "IPs privadas de los web servers"
}

output "ssh_command" {
  value       = format("ssh -i .ssh/%s-wp-key.pem ubuntu@%s", var.environment, aws_instance.web[0].private_ip)
  description = "Comando SSH al primer web server"
}
