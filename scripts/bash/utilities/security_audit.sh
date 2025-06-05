#!/bin/bash
# Realiza chequeos básicos de seguridad y notificaciones a Slack

LOG_FILE="/var/log/security_audit.log"
ALERT_THRESHOLD=1
ALERT_COUNT=0
SLACK_REPORTER="python3 ./slack_reporter.py"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Notificar inicio de auditoría
$SLACK_REPORTER "info" "Inicio Auditoría Seguridad" "Se inició la auditoría de seguridad en $TIMESTAMP."

{
  echo "=== INICIO AUDITORIA $(date) ==="
  
  # 1. Check root SSH access
  if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
    echo "ALERTA: Root login habilitado en SSH"
    ((ALERT_COUNT++))
  fi
  
  # 2. Check passwordless sudo
  for user in $(getent passwd | cut -d: -f1); do
    if sudo -lU "$user" | grep -q "NOPASSWD"; then
      echo "ALERTA: Sudo sin contraseña para $user"
      ((ALERT_COUNT++))
    fi
  done
  
  # 3. Check world-writable files
  find / -xdev -type f -perm -0002 2>/dev/null | while read -r file; do
    echo "ALERTA: Archivo world-writable: $file"
    ((ALERT_COUNT++))
  done
  
  # 4. Check admin API keys
  for key in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY; do
    if env | grep -q "$key"; then
      echo "ALERTA: Variable sensible $key en entorno"
      ((ALERT_COUNT++))
    fi
  done
  
  echo "=== RESUMEN ==="
  echo "Total alertas: $ALERT_COUNT"
  
  echo "=== FIN AUDITORIA $(date) ==="
} >> "$LOG_FILE" 2>&1

# Notificar resultado de auditoría
if [ $ALERT_COUNT -ge $ALERT_THRESHOLD ]; then
  $SLACK_REPORTER "critical" "Auditoría Seguridad - Alertas" "Se encontraron $ALERT_COUNT alertas de seguridad. Revisa el log: $LOG_FILE"
else
  $SLACK_REPORTER "info" "Auditoría Seguridad Sin Alertas" "No se detectaron alertas de seguridad. Total=0."
fi
