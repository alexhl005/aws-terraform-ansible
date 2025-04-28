resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(var.subnet_ids, count.index)
  vpc_security_group_ids = [aws_security_group.ec2.id]
  associate_public_ip_address = false
  key_name      = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              # ==============================================
              # CONFIGURACIÓN INICIAL
              # ==============================================
              apt-get update
              apt-get install -y python3-pip awscli unzip
              pip3 install boto3 psutil requests
              
              # ==============================================
              # ESTRUCTURA DE DIRECTORIOS
              # ==============================================
              mkdir -p ~/scripts/{bash,monitoring,python}
              mkdir -p ~/scripts/bash/{backup,utilities}
              mkdir -p /opt/aws-monitoring
              mkdir -p /var/log
              
              # ==============================================
              # SCRIPTS BASH
              # ==============================================
              
              # 1. Backup - s3_sync.sh
              cat > ~/scripts/bash/backup/s3_sync.sh << 'BASH_SCRIPT'
              #!/bin/bash
              WP_UPLOADS_DIR="/var/www/html/wp-content/uploads"
              S3_BUCKET="s3://your-backup-bucket"
              LOG_FILE="/var/log/wp_uploads_s3_sync.log"
              
              {
                echo "=== Inicio Sync WP Uploads S3 $(date) ==="
                aws s3 sync $WP_UPLOADS_DIR $S3_BUCKET \\
                  --exclude "*" \\
                  --include "*/[0-9][0-9][0-9][0-9]/[0-9][0-9]/*" \\
                  --no-progress
                
                for year_month_dir in \$(find $WP_UPLOADS_DIR -maxdepth 2 -type d -regextype sed -regex ".*/[0-9]\\{4\\}/[0-9]\\{2\\}\$"); do
                  year=\$(basename \$(dirname $year_month_dir))
                  month=\$(basename $year_month_dir)
                  aws s3api put-object-tagging \\
                    --bucket your-backup-bucket \\
                    --key "wp-uploads/\$year/\$month/" \\
                    --tagging '{"TagSet": [{"Key": "expire_rule", "Value": "30d_standard_90d_glacier"}]}'
                done
                
                echo "=== Fin Sync WP Uploads S3 $(date) ==="
                aws s3 ls $S3_BUCKET --recursive --human-readable --summarize | tail -n 2
              } >> \$LOG_FILE 2>&1
              BASH_SCRIPT
              
              # 2. Monitoring - check_services.sh
              cat > ~/scripts/monitoring/check_services.sh << 'BASH_SCRIPT'
              #!/bin/bash
              SERVICES="apache2 php-fpm cron rsyslog"
              TIMESTAMP=\$(date "+%Y-%m-%d %H:%M:%S")
              LOG_FILE="/var/log/wordpress_service_monitor.log"
              
              {
                echo "=== Monitoreo de WordPress - \$TIMESTAMP ==="
                for service in "\${SERVICES[*]}"; do
                  if systemctl is-active --quiet \$service; then
                    echo "[OK] \$service está en ejecución"
                  else
                    echo "[CRÍTICO] \$service está caído - Intentando reinicio..."
                    systemctl restart \$service
                    sleep 3
                    if systemctl is-active --quiet \$service; then
                      echo "[RECUPERADO] \$service se reinició exitosamente"
                      ~/scripts/python/slack_reporter.py "warning" "Servicio \$service reiniciado" "El servicio \$service estaba caído pero se reinició automáticamente."
                    else
                      echo "[FALLO] No se pudo reiniciar \$service"
                      ~/scripts/python/slack_reporter.py "critical" "Fallo en \$service" "El servicio \$service está caído y no se pudo reiniciar automáticamente. ¡Se requiere intervención manual!"
                    fi
                  fi
                done
                echo "=== Fin del monitoreo ==="
              } >> \$LOG_FILE 2>&1
              BASH_SCRIPT
              
              # 3. Monitoring - log_analyzer.sh
              cat > ~/scripts/monitoring/log_analyzer.sh << 'BASH_SCRIPT'
              #!/bin/bash
              LOG_DIR="/var/log"
              ERROR_PATTERNS=(
                  "Out of memory"
                  "Killed process"
                  "segmentation fault"
                  "Critical error"
              )
              REPORT_FILE="\$LOG_DIR/error_report.log"
              THRESHOLD=1
              
              analyze_logs() {
                  local count=0
                  echo "Reporte generado: \$(date)" > \$REPORT_FILE
                  
                  for pattern in "\${ERROR_PATTERNS[*]}"; do
                      echo "=== Patrón: \$pattern ===" >> \$REPORT_FILE
                      grep -i "\$pattern" \$LOG_DIR/*.log >> \$REPORT_FILE
                      matches=\$(grep -ci "\$pattern" \$LOG_DIR/*.log)
                      ((count += matches))
                  done
                  
                  if [ \$count -gt \$THRESHOLD ]; then
                      ~/scripts/python/slack_reporter.py \\
                          "warning" "Alto número de errores detectados" "Se encontraron \$count errores críticos. Ver \$REPORT_FILE"
                  fi
              }
              
              analyze_logs
              BASH_SCRIPT
              
              # 4. Utilities - cleanup.sh
              cat > ~/scripts/bash/utilities/cleanup.sh << 'BASH_SCRIPT'
              #!/bin/bash
              LOG_FILE="/var/log/cleanup.log"
              DAYS_TO_KEEP=30
              
              {
                echo "=== INICIO LIMPIEZA \$(date) ==="
                find /var/log -name "*.log" -mtime +\$DAYS_TO_KEEP -delete
                rm -rf /tmp/* /var/tmp/*
                echo "=== FIN LIMPIEZA \$(date) ==="
              } >> \$LOG_FILE 2>&1
              BASH_SCRIPT
              
              # 5. Utilities - security_audit.sh
              cat > ~/scripts/bash/utilities/security_audit.sh << 'BASH_SCRIPT'
              #!/bin/bash
              LOG_FILE="/var/log/security_audit.log"
              ALERT_THRESHOLD=1
              ALERT_COUNT=0
              
              {
                echo "=== INICIO AUDITORIA \$(date) ==="
                if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
                  echo "ALERTA: Root login habilitado en SSH"
                  ((ALERT_COUNT++))
                fi
                
                for user in \$(getent passwd | cut -d: -f1); do
                  if sudo -lU \$user | grep -q "NOPASSWD"; then
                    echo "ALERTA: Sudo sin contraseña para \$user"
                    ((ALERT_COUNT++))
                  fi
                done
                
                find / -xdev -type f -perm -0002 2>/dev/null | while read file; do
                  echo "ALERTA: Archivo world-writable: \$file"
                  ((ALERT_COUNT++))
                done
                
                for key in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY; do
                  if env | grep -q "\$key"; then
                    echo "ALERTA: Variable sensible \$key en entorno"
                    ((ALERT_COUNT++))
                  fi
                done
                
                echo "=== RESUMEN ==="
                echo "Total alertas: \$ALERT_COUNT"
                
                if [ \$ALERT_COUNT -ge \$ALERT_THRESHOLD ]; then
                  ~/scripts/python/slack_reporter.py \\
                      "critical" "Auditoría de seguridad" "Se detectaron \$ALERT_COUNT problemas de seguridad"
                fi
              } >> \$LOG_FILE 2>&1
              BASH_SCRIPT
              
              # 6. Utilities - weekly_maintenance.sh
              cat > ~/scripts/bash/utilities/weekly_maintenance.sh << 'BASH_SCRIPT'
              #!/bin/bash
              LOG_FILE="/var/log/weekly_maintenance.log"
              {
                echo "=== INICIO MANTENIMIENTO \$(date) ==="
                apt-get autoremove -y
                logrotate -f /etc/logrotate.conf
                df -h
                du -sh /var/log/*
                updatedb
                echo "=== FIN MANTENIMIENTO \$(date) ==="
              } >> \$LOG_FILE 2>&1
              ~/scripts/python/slack_reporter.py "info" "Mantenimiento semanal" "Mantenimiento semanal completado"
              BASH_SCRIPT
              
              # ==============================================
              # SCRIPTS PYTHON
              # ==============================================
              
              # 1. CloudWatch Alerts
              cat > /opt/aws-monitoring/cloudwatch_alerts.py << 'PYTHON_SCRIPT'
              #!/usr/bin/env python3
              import boto3
              import psutil
              from datetime import datetime
              
              cloudwatch = boto3.client('cloudwatch')
              INSTANCE_ID = open('/var/lib/cloud/data/instance-id').read().strip()
              
              def report_metrics():
                  metrics = [
                      {'MetricName': 'CPUUtilization', 'Value': psutil.cpu_percent(interval=1), 'Unit': 'Percent'},
                      {'MetricName': 'MemoryUtilization', 'Value': psutil.virtual_memory().percent, 'Unit': 'Percent'},
                      {'MetricName': 'DiskSpaceUtilization', 'Value': psutil.disk_usage('/').percent, 'Unit': 'Percent'},
                      {'MetricName': 'NetworkIn', 'Value': psutil.net_io_counters().bytes_recv, 'Unit': 'Bytes'},
                      {'MetricName': 'NetworkOut', 'Value': psutil.net_io_counters().bytes_sent, 'Unit': 'Bytes'}
                  ]
                  cloudwatch.put_metric_data(
                      Namespace='Custom/EC2',
                      MetricData=[{
                          **metric,
                          'Dimensions': [{'Name': 'InstanceId', 'Value': INSTANCE_ID}],
                          'Timestamp': datetime.utcnow()
                      } for metric in metrics]
                  )
              
              if __name__ == "__main__":
                  report_metrics()
              PYTHON_SCRIPT
              
              # 2. Slack Reporter
              cat > ~/scripts/python/slack_reporter.py << 'PYTHON_SCRIPT'
              #!/usr/bin/env python3
              import sys
              import json
              import requests
              from datetime import datetime
              
              SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/TXXXXXX/BXXXXXX/XXXXXXXXXX"
              SITE_NAME = "Mi WordPress"
              ENVIRONMENT = "prod"
              
              COLORS = {
                  "info": "#3498db",
                  "warning": "#f39c12",
                  "critical": "#e74c3c",
                  "success": "#2ecc71"
              }
              
              def send_slack_alert(level, title, message):
                  payload = {
                      "attachments": [
                          {
                              "color": COLORS.get(level.lower(), COLORS["info"]),
                              "title": f":wordpress: {SITE_NAME} - {title}",
                              "text": message,
                              "fields": [
                                  {"title": "Entorno", "value": ENVIRONMENT, "short": True},
                                  {"title": "Nivel", "value": level.upper(), "short": True},
                                  {"title": "Fecha", "value": datetime.now().strftime("%Y-%m-%d %H:%M:%S"), "short": False}
                              ],
                              "footer": "Monitor de WordPress",
                              "ts": datetime.now().timestamp()
                          }
                      ]
                  }
                  
                  try:
                      response = requests.post(
                          SLACK_WEBHOOK_URL,
                          data=json.dumps(payload),
                          headers={"Content-Type": "application/json"}
                      )
                      return response.status_code == 200
                  except Exception as e:
                      print(f"Error enviando a Slack: {str(e)}", file=sys.stderr)
                      return False
              
              if __name__ == "__main__":
                  if len(sys.argv) < 4:
                      print("Uso: slack_reporter.py [nivel] [título] [mensaje]")
                      sys.exit(1)
                  
                  level = sys.argv[1]
                  title = sys.argv[2]
                  message = " ".join(sys.argv[3:])
                  
                  success = send_slack_alert(level, title, message)
                  sys.exit(0 if success else 1)
              PYTHON_SCRIPT
              
              # ==============================================
              # CONFIGURACIÓN FINAL
              # ==============================================
              
              # Permisos de ejecución
              chmod +x ~/scripts/bash/backup/s3_sync.sh
              chmod +x ~/scripts/monitoring/check_services.sh
              chmod +x ~/scripts/monitoring/log_analyzer.sh
              chmod +x ~/scripts/bash/utilities/cleanup.sh
              chmod +x ~/scripts/bash/utilities/security_audit.sh
              chmod +x ~/scripts/bash/utilities/weekly_maintenance.sh
              chmod +x /opt/aws-monitoring/cloudwatch_alerts.py
              chmod +x ~/scripts/python/slack_reporter.py
              
              # Configurar servicio CloudWatch
              cat > /etc/systemd/system/cloudwatch-metrics.service << 'SERVICE_CONFIG'
              [Unit]
              Description=Envía métricas de sistema a AWS CloudWatch
              After=network.target
              
              [Service]
              Type=simple
              User=root
              ExecStart=/usr/bin/python3 /opt/aws-monitoring/cloudwatch_alerts.py
              Restart=on-failure
              RestartSec=60
              
              [Install]
              WantedBy=multi-user.target
              SERVICE_CONFIG
              
              # Habilitar servicios
              systemctl daemon-reload
              systemctl enable cloudwatch-metrics
              systemctl start cloudwatch-metrics
              
              # Configurar Cronjobs
              (crontab -l 2>/dev/null; echo "59 23 * * 0 ~/scripts/bash/backup/s3_sync.sh") | crontab -
              (crontab -l 2>/dev/null; echo "*/5 * * * * ~/scripts/monitoring/check_services.sh") | crontab -
              (crontab -l 2>/dev/null; echo "0 0 * * * ~/scripts/bash/utilities/cleanup.sh") | crontab -
              (crontab -l 2>/dev/null; echo "0 12 * * 1 ~/scripts/bash/utilities/security_audit.sh") | crontab -
              (crontab -l 2>/dev/null; echo "0 3 * * 0 ~/scripts/bash/utilities/weekly_maintenance.sh") | crontab -
              (crontab -l 2>/dev/null; echo "0 1 * * * ~/scripts/monitoring/log_analyzer.sh") | crontab -
              EOF

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