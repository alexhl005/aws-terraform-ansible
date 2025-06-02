#!/bin/bash
# Analiza los logs de múltiples scripts de WordPress y envía alertas a Slack

SLACK_REPORTER="/usr/bin/python3 ~/slack_reporter.py"
TIMESTAMP() { date "+%Y-%m-%d %H:%M:%S"; }

# Verificamos que slack_reporter.py exista y sea ejecutable
if [ ! -x "$(echo $SLACK_REPORTER | cut -d' ' -f2)" ]; then
  echo "ERROR: No se encontró o no es ejecutable slack_reporter.py en la ruta esperada." >&2
  exit 1
fi

# ------------------------------------------------------------------------
# 1. analyze_service_monitor: chequea wordpress_service_monitor.log
# ------------------------------------------------------------------------
analyze_service_monitor() {
  LOG_FILE="/var/log/wordpress_service_monitor.log"
  PATTERNS=("CRÍTICO" "FALLO" "ERROR")
  local total_matches=0

  if [ ! -f "$LOG_FILE" ]; then
    echo "Sin log de monitoreo de servicios ($LOG_FILE). Saltando..." >&2
    return
  fi

  # Contar coincidencias por patrón
  for pat in "${PATTERNS[@]}"; do
    count=$(grep -ci "$pat" "$LOG_FILE" 2>/dev/null || echo 0)
    total_matches=$(( total_matches + count ))
  done

  if [ "$total_matches" -gt 0 ]; then
    # Tomamos hasta 5 líneas de contexto de los patrones encontrados
    sample=$(grep -iE "$(IFS=\|; echo "${PATTERNS[*]}")" "$LOG_FILE" | head -n 5)
    level="warning"
    title="Monitoreo de Servicios"
    message="Se detectaron *$total_matches* problemas en wordpress_service_monitor.log – $(TIMESTAMP)\n\`\`\`$sample\`\`\`"
    $SLACK_REPORTER "$level" "$title" "$message"
  else
    level="success"
    title="Monitoreo de Servicios"
    message="No se detectaron errores críticos en wordpress_service_monitor.log – $(TIMESTAMP)"
    $SLACK_REPORTER "$level" "$title" "$message"
  fi
}

# ------------------------------------------------------------------------
# 2. analyze_wp_sync: chequea wp_uploads_s3_sync.log
# ------------------------------------------------------------------------
analyze_wp_sync() {
  LOG_FILE="/var/log/wp_uploads_s3_sync.log"
  if [ ! -f "$LOG_FILE" ]; then
    echo "Sin log de WP-S3 Sync ($LOG_FILE). Saltando..." >&2
    return
  fi

  # Buscar líneas que contengan “error”, “failed” o “exit code”
  errors=$(grep -iE "error|failed|exit code" "$LOG_FILE" 2>/dev/null)
  count=$(echo "$errors" | grep -c '^' || echo 0)

  if [ "$count" -gt 0 ]; then
    sample=$(echo "$errors" | head -n 3)
    level="warning"
    title="Sync WP→S3"
    message="Se encontraron *$count* líneas con “error/failed” en wp_uploads_s3_sync.log – $(TIMESTAMP)\n\`\`\`$sample\`\`\`"
    $SLACK_REPORTER "$level" "$title" "$message"
  else
    level="success"
    title="Sync WP→S3"
    message="Sin errores detectados en wp_uploads_s3_sync.log – $(TIMESTAMP)"
    $SLACK_REPORTER "$level" "$title" "$message"
  fi
}

# ------------------------------------------------------------------------
# 3. analyze_cleanup: chequea cleanup.log
# ------------------------------------------------------------------------
analyze_cleanup() {
  LOG_FILE="/var/log/cleanup.log"
  if [ ! -f "$LOG_FILE" ]; then
    echo "Sin log de limpieza ($LOG_FILE). Saltando..." >&2
    return
  fi

  errors=$(grep -iE "cannot|permission denied|error" "$LOG_FILE" 2>/dev/null)
  count=$(echo "$errors" | grep -c '^' || echo 0)

  if [ "$count" -gt 0 ]; then
    sample=$(echo "$errors" | head -n 3)
    level="warning"
    title="Limpieza de Archivos"
    message="Se detectaron *$count* posibles fallos en cleanup.log – $(TIMESTAMP)\n\`\`\`$sample\`\`\`"
    $SLACK_REPORTER "$level" "$title" "$message"
  else
    level="success"
    title="Limpieza de Archivos"
    message="cleanup.log ejecutado sin errores – $(TIMESTAMP)"
    $SLACK_REPORTER "$level" "$title" "$message"
  fi
}

# ------------------------------------------------------------------------
# 4. analyze_security: chequea security_audit.log
# ------------------------------------------------------------------------
analyze_security() {
  LOG_FILE="/var/log/security_audit.log"
  if [ ! -f "$LOG_FILE" ]; then
    echo "Sin log de auditoría de seguridad ($LOG_FILE). Saltando..." >&2
    return
  fi

  total_alerts=$(grep -ci "ALERTA" "$LOG_FILE" 2>/dev/null || echo 0)
  if [ "$total_alerts" -gt 0 ]; then
    sample=$(grep -i "ALERTA" "$LOG_FILE" | head -n 3)
    level="critical"
    title="Auditoría de Seguridad"
    message="Se detectaron *$total_alerts* alertas en security_audit.log – $(TIMESTAMP)\n\`\`\`$sample\`\`\`"
    $SLACK_REPORTER "$level" "$title" "$message"
  else
    level="success"
    title="Auditoría de Seguridad"
    message="No se encontraron alertas en security_audit.log – $(TIMESTAMP)"
    $SLACK_REPORTER "$level" "$title" "$message"
  fi
}

# ------------------------------------------------------------------------
# 5. analyze_maintenance: chequea weekly_maintenance.log
# ------------------------------------------------------------------------
analyze_maintenance() {
  LOG_FILE="/var/log/weekly_maintenance.log"
  if [ ! -f "$LOG_FILE" ]; then
    echo "Sin log de mantenimiento semanal ($LOG_FILE). Saltando..." >&2
    return
  fi

  errors=$(grep -iE "error|fail" "$LOG_FILE" 2>/dev/null)
  count=$(echo "$errors" | grep -c '^' || echo 0)

  if [ "$count" -gt 0 ]; then
    sample=$(echo "$errors" | head -n 3)
    level="warning"
    title="Mantenimiento Semanal"
    message="Se detectaron *$count* posibles fallos en weekly_maintenance.log – $(TIMESTAMP)\n\`\`\`$sample\`\`\`"
    $SLACK_REPORTER "$level" "$title" "$message"
  else
    level="success"
    title="Mantenimiento Semanal"
    message="weekly_maintenance.log completado sin errores – $(TIMESTAMP)"
    $SLACK_REPORTER "$level" "$title" "$message"
  fi
}

analyze_service_monitor
analyze_wp_sync
analyze_cleanup
analyze_security
analyze_maintenance