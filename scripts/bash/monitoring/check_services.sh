#!/bin/bash
# Monitor de servicios esenciales para WordPress (excepto BD)
# Verifica Apache, PHP-FPM y otros servicios críticos

SERVICES=("apache2" "php-fpm" "cron" "rsyslog")  # Servicios típicos de WordPress
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
LOG_FILE="/var/log/wordpress_service_monitor.log"
SLACK_REPORTER="/usr/local/bin/slack_reporter.py"  # Ruta al script Python

{
  echo "=== Monitoreo de WordPress - $TIMESTAMP ==="
  
  for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet $service; then
      echo "[OK] $service está en ejecución"
    else
      echo "[CRÍTICO] $service está caído - Intentando reinicio..."
      systemctl restart $service
      
      # Verificar si el reinicio fue exitoso
      sleep 3  # Pequeño delay para permitir el reinicio
      if systemctl is-active --quiet $service; then
        echo "[RECUPERADO] $service se reinició exitosamente"
        $SLACK_REPORTER "warning" "Servicio $service reiniciado" "El servicio $service estaba caído pero se reinició automáticamente."
      else
        echo "[FALLO] No se pudo reiniciar $service"
        $SLACK_REPORTER "critical" "Fallo en $service" "El servicio $service está caído y no se pudo reiniciar automáticamente. ¡Se requiere intervención manual!"
      fi
    fi
  done
  
  echo "=== Fin del monitoreo ==="
  echo ""
} >> $LOG_FILE 2>&1  # Redirige tanto stdout como stderr al log