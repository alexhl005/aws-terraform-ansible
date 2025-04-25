#!/bin/bash
# Verifica servicios y envía alertas

SERVICES=("nginx" "mysql" "php-fpm")
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
LOG_FILE="/var/log/service_monitor.log"

{
  echo "=== $TIMESTAMP ==="
  for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet $service; then
      echo "STATUS_OK: $service"
    else
      echo "STATUS_CRITICAL: $service - Intentando reinicio"
      systemctl restart $service
      /usr/bin/python3 "$(dirname "$0")/../../python/monitoring/slack_reporter.py" "$service caído - Reiniciado"
    fi
  done
} >> $LOG_FILE