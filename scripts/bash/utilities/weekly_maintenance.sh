#!/bin/bash
# Tareas de mantenimiento semanal y notificaciones a Slack

LOG_FILE="/var/log/weekly_maintenance.log"
SLACK_REPORTER="python3 ./slack_reporter.py"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Notificar inicio de mantenimiento
$SLACK_REPORTER "maintenance" "Inicio Mantenimiento Semanal" "Se inició el mantenimiento semanal en $TIMESTAMP."

{
  echo "=== INICIO MANTENIMIENTO $(date) ==="
  
  # 1. Limpieza de paquetes
  apt-get autoremove -y
  APT_EXIT_CODE=$?
  if [ $APT_EXIT_CODE -ne 0 ]; then
    echo "[WARNING] Falló apt-get autoremove"
    $SLACK_REPORTER "warning" "Mantenimiento - autoremove Fallido" "Falló 'apt-get autoremove' con código $APT_EXIT_CODE."
  else
    echo "[OK] apt-get autoremove completado"
  fi
  
  # 2. Rotación de logs
  logrotate -f /etc/logrotate.conf
  LOGROTATE_EXIT_CODE=$?
  if [ $LOGROTATE_EXIT_CODE -ne 0 ]; then
    echo "[WARNING] Falló logrotate"
    $SLACK_REPORTER "warning" "Mantenimiento - logrotate Fallido" "Falló 'logrotate' con código $LOGROTATE_EXIT_CODE."
  else
    echo "[OK] Rotación de logs completada"
  fi
  
  # 3. Verificación de discos
  df -h
  DU_EXIT_CODE=$?
  if [ $DU_EXIT_CODE -ne 0 ]; then
    echo "[WARNING] Falló df -h o du -sh"
    $SLACK_REPORTER "warning" "Mantenimiento - Verif. Discos Fallido" "Error al ejecutar 'df -h' o 'du -sh'."
  else
    echo "[OK] Verificación de discos completada"
  fi
  
  # 4. Actualización de índices de búsqueda
  updatedb
  UPDATEDB_EXIT_CODE=$?
  if [ $UPDATEDB_EXIT_CODE -ne 0 ]; then
    echo "[WARNING] Falló updatedb"
    $SLACK_REPORTER "warning" "Mantenimiento - updatedb Fallido" "Falló 'updatedb' con código $UPDATEDB_EXIT_CODE."
  else
    echo "[OK] Índice de búsqueda actualizado"
  fi
  
  echo "=== FIN MANTENIMIENTO $(date) ==="
} >> "$LOG_FILE" 2>&1

# Notificar fin de mantenimiento
FIN_TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
$SLACK_REPORTER "info" "Mantenimiento Semanal Finalizado" "El mantenimiento semanal concluyó en $FIN_TIMESTAMP."
