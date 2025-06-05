#!/bin/bash
# Cleanup old files y notificaciones a Slack

LOG_FILE="/var/log/cleanup.log"
DAYS_TO_KEEP=30
SLACK_REPORTER="python3 ./slack_reporter.py"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Notificar inicio de limpieza
$SLACK_REPORTER "maintenance" "Inicio Limpieza" "Se inició el proceso de limpieza de archivos en $TIMESTAMP."

{
  echo "=== INICIO LIMPIEZA $(date) ==="
  
  # 1. Cleanup old logs
  find /var/log -name "*.log" -mtime +$DAYS_TO_KEEP -delete
  FIND_EXIT_CODE=$?
  if [ $FIND_EXIT_CODE -ne 0 ]; then
    echo "[WARNING] Falló la eliminación de logs antiguos"
    $SLACK_REPORTER "warning" "Limpieza Logs Fallida" "No se pudieron eliminar algunos logs con más de $DAYS_TO_KEEP días."
  else
    echo "[OK] Logs antiguos eliminados"
  fi
  
  # 2. Temp files
  rm -rf /tmp/* /var/tmp/*
  RM_EXIT_CODE=$?
  if [ $RM_EXIT_CODE -ne 0 ]; then
    echo "[WARNING] Falló la limpieza de directorios temporales"
    $SLACK_REPORTER "warning" "Limpieza Temp Fallida" "No se pudieron eliminar algunos archivos temporales."
  else
    echo "[OK] Archivos temporales eliminados"
  fi
  
  echo "=== FIN LIMPIEZA $(date) ==="
} >> "$LOG_FILE" 2>&1

# Notificar fin de limpieza
FIN_TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
$SLACK_REPORTER "info" "Limpieza Finalizada" "El proceso de limpieza finalizó correctamente en $FIN_TIMESTAMP."
